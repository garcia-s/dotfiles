package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

// --- /proc/stat CPU parsing ---

type cpuStat struct {
	total, idle int64
}

func readCPUStat() map[string]cpuStat {
	f, err := os.Open("/proc/stat")
	if err != nil {
		return nil
	}
	defer f.Close()

	result := make(map[string]cpuStat)
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 8 || !strings.HasPrefix(fields[0], "cpu") {
			continue
		}
		var vals [7]int64
		for i := 0; i < 7 && i+1 < len(fields); i++ {
			vals[i], _ = strconv.ParseInt(fields[i+1], 10, 64)
		}
		total := vals[0] + vals[1] + vals[2] + vals[3] + vals[4] + vals[5] + vals[6]
		idle := vals[3] // idle only (matching original awk $5)
		result[fields[0]] = cpuStat{total, idle}
	}
	return result
}

func cpuPct(prev, curr cpuStat) int {
	dt := curr.total - prev.total
	di := curr.idle - prev.idle
	if dt <= 0 {
		return 0
	}
	pct := int((1.0 - float64(di)/float64(dt)) * 100)
	if pct < 0 {
		return 0
	}
	if pct > 100 {
		return 100
	}
	return pct
}

// --- /proc/meminfo ---

func readMemInfo() (totalKB, availKB int64) {
	f, err := os.Open("/proc/meminfo")
	if err != nil {
		return 1, 0
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		fields := strings.Fields(scanner.Text())
		if len(fields) < 2 {
			continue
		}
		val, _ := strconv.ParseInt(fields[1], 10, 64)
		switch fields[0] {
		case "MemTotal:":
			totalKB = val
		case "MemAvailable:":
			availKB = val
		}
	}
	return
}

func ramPct() int {
	total, avail := readMemInfo()
	if total <= 0 {
		return 0
	}
	return int(float64(total-avail) / float64(total) * 100)
}

// --- GPU (multi-backend) ---

type gpuBackend struct {
	kind    string // "nvidia-smi", "nvidia-settings", "amd", "none"
	amdCard string // AMD: /sys/class/drm/cardX/device
	total   int64  // cached total VRAM (MB for nvidia-settings, bytes for AMD)
}

// initGPU detects the available GPU backend once at startup.
func initGPU() gpuBackend {
	// 1. nvidia-smi — full NVIDIA stats
	if _, err := exec.LookPath("nvidia-smi"); err == nil {
		return gpuBackend{kind: "nvidia-smi"}
	}
	// 2. nvidia-settings — NVIDIA memory only (no utilization source)
	if _, err := exec.LookPath("nvidia-settings"); err == nil {
		out, err := exec.Command("nvidia-settings", "-q", "TotalDedicatedGPUMemory", "-t").Output()
		if err == nil {
			if total, _ := strconv.ParseInt(strings.TrimSpace(string(out)), 10, 64); total > 0 {
				return gpuBackend{kind: "nvidia-settings", total: total}
			}
		}
	}
	// 3. AMD sysfs — full stats via /sys/class/drm
	cards, _ := filepath.Glob("/sys/class/drm/card*/device")
	for _, dev := range cards {
		v, _ := os.ReadFile(filepath.Join(dev, "vendor"))
		if strings.TrimSpace(string(v)) != "0x1002" {
			continue
		}
		t, _ := os.ReadFile(filepath.Join(dev, "mem_info_vram_total"))
		total, _ := strconv.ParseInt(strings.TrimSpace(string(t)), 10, 64)
		return gpuBackend{kind: "amd", amdCard: dev, total: total}
	}
	return gpuBackend{kind: "none"}
}

// stats returns GPU utilization and VRAM usage as percentage strings, or "N/A".
func (g *gpuBackend) stats() (utilStr, memStr string) {
	utilStr, memStr = "N/A", "N/A"
	switch g.kind {
	case "nvidia-smi":
		out, err := exec.Command("nvidia-smi",
			"--query-gpu=utilization.gpu,memory.used,memory.total",
			"--format=csv,noheader,nounits").Output()
		if err != nil {
			return
		}
		line := strings.TrimSpace(strings.SplitN(string(out), "\n", 2)[0])
		parts := strings.SplitN(line, ", ", 3)
		if len(parts) < 3 {
			parts = strings.SplitN(line, ",", 3)
		}
		if len(parts) < 3 {
			return
		}
		gu, _ := strconv.Atoi(strings.TrimSpace(parts[0]))
		used, _ := strconv.Atoi(strings.TrimSpace(parts[1]))
		total, _ := strconv.Atoi(strings.TrimSpace(parts[2]))
		utilStr = strconv.Itoa(gu)
		if total > 0 {
			memStr = strconv.Itoa(used * 100 / total)
		}
	case "nvidia-settings":
		// total is cached (MB); query used each interval
		out, err := exec.Command("nvidia-settings", "-q", "UsedDedicatedGPUMemory", "-t").Output()
		if err != nil {
			return
		}
		used, _ := strconv.ParseInt(strings.TrimSpace(string(out)), 10, 64)
		if g.total > 0 {
			memStr = strconv.Itoa(int(used * 100 / g.total))
		}
		// utilStr stays "N/A" — no utilization source without nvidia-smi
	case "amd":
		b, err := os.ReadFile(filepath.Join(g.amdCard, "gpu_busy_percent"))
		if err == nil {
			utilStr = strings.TrimSpace(string(b))
		}
		u, err := os.ReadFile(filepath.Join(g.amdCard, "mem_info_vram_used"))
		if err == nil && g.total > 0 {
			used, _ := strconv.ParseInt(strings.TrimSpace(string(u)), 10, 64)
			memStr = strconv.Itoa(int(used * 100 / g.total))
		}
	}
	return
}

// --- subcommands ---

// runStats feeds Bar.qml: CPU:XX|RAM:XX|GPU_UTIL:XX|GPU_MEM:XX every 1s
func runStats() {
	prev := readCPUStat()
	time.Sleep(time.Second)
	g := initGPU()
	w := bufio.NewWriter(os.Stdout)
	for {
		curr := readCPUStat()
		cpu := cpuPct(prev["cpu"], curr["cpu"])
		prev = curr

		ram := ramPct()
		utilStr, memStr := g.stats()
		fmt.Fprintf(w, "CPU:%d|RAM:%d|GPU_UTIL:%s|GPU_MEM:%s\n", cpu, ram, utilStr, memStr)
		w.Flush()
		time.Sleep(time.Second)
	}
}

// runCPU feeds CpuDetails.qml: per-core "<idx>:<pct>" lines then "---" every 1s
func runCPU() {
	prev := readCPUStat()
	time.Sleep(time.Second)
	w := bufio.NewWriter(os.Stdout)
	for {
		curr := readCPUStat()

		var indices []int
		for key := range curr {
			if key == "cpu" {
				continue
			}
			idx, err := strconv.Atoi(strings.TrimPrefix(key, "cpu"))
			if err != nil {
				continue
			}
			indices = append(indices, idx)
		}
		sort.Ints(indices)

		for _, idx := range indices {
			key := fmt.Sprintf("cpu%d", idx)
			fmt.Fprintf(w, "%d:%d\n", idx, cpuPct(prev[key], curr[key]))
		}
		fmt.Fprintln(w, "---")
		w.Flush()
		prev = curr
		time.Sleep(time.Second)
	}
}

// runRAM feeds RamDetails.qml: TOTAL:MB, proc:MB lines, "---" every 3s
func runRAM() {
	totalKB, _ := readMemInfo()
	totalMB := totalKB / 1024
	w := bufio.NewWriter(os.Stdout)
	for {
		fmt.Fprintf(w, "TOTAL:%d\n", totalMB)
		for _, p := range topProcs(8) {
			fmt.Fprintf(w, "%s:%d\n", p.name, p.rssMB)
		}
		fmt.Fprintln(w, "---")
		w.Flush()
		time.Sleep(3 * time.Second)
	}
}

type procInfo struct {
	name  string
	rssMB int
}

func topProcs(n int) []procInfo {
	entries, _ := os.ReadDir("/proc")
	var procs []procInfo
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		pid, err := strconv.Atoi(e.Name())
		if err != nil || pid <= 0 {
			continue
		}
		f, err := os.Open("/proc/" + e.Name() + "/status")
		if err != nil {
			continue
		}
		var name string
		var rssKB int64
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "Name:") {
				name = strings.TrimSpace(strings.TrimPrefix(line, "Name:"))
			} else if strings.HasPrefix(line, "VmRSS:") {
				fields := strings.Fields(line)
				if len(fields) >= 2 {
					rssKB, _ = strconv.ParseInt(fields[1], 10, 64)
				}
			}
		}
		f.Close()
		if name != "" && rssKB > 0 {
			procs = append(procs, procInfo{name, int(rssKB / 1024)})
		}
	}
	sort.Slice(procs, func(i, j int) bool {
		return procs[i].rssMB > procs[j].rssMB
	})
	if len(procs) > n {
		procs = procs[:n]
	}
	return procs
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: qs-sysmon <stats|cpu|ram>")
		os.Exit(1)
	}
	switch os.Args[1] {
	case "stats":
		runStats()
	case "cpu":
		runCPU()
	case "ram":
		runRAM()
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n", os.Args[1])
		os.Exit(1)
	}
}
