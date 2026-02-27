import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: barRoot

    anchors { top: true; left: true; right: true }
    margins { top: 10; left: 10; right: 10 }
    implicitHeight: 40
    color: "transparent"
    exclusiveZone: 40

    // Signals — handled by shell.qml which owns the popup instances
    signal toggleAppMenuRequested()
    signal togglePowerMenuRequested()
    signal toggleCalendarRequested()
    signal toggleCpuDetailsRequested()
    signal toggleRamDetailsRequested()

    // Item refs exposed for PopupWindow anchoring
    property alias appMenuButtonRef: appMenuBtn
    property alias powerMenuButtonRef: powerMenuBtn
    property alias clockRef: clockItem
    property alias cpuRef: cpuItem
    property alias ramRef: ramItem

    // Stats values
    property string cpuVal: "--"
    property string ramVal: "--"
    property string gpuUtil: "--"
    property string gpuMem: "--"

    // Clock
    property string clockTime: Qt.formatTime(new Date(), "hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: barRoot.clockTime = Qt.formatTime(new Date(), "hh:mm")
    }

    // System stats process
    Process {
        id: statsProc
        running: true
        command: [
            "bash", "-c",
            "prev=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5; exit}' /proc/stat); " +
            "while true; do " +
            "  sleep 1; " +
            "  curr=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5; exit}' /proc/stat); " +
            "  cpu=$(echo \"$prev $curr\" | awk '{dt=$3-$1; di=$4-$2; c=(dt>0)?int((1-di/dt)*100):0; print (c<0)?0:(c>100?100:c)}'); " +
            "  prev=$curr; " +
            "  ram=$(free | awk 'NR==2{print int($3*100/$2)}'); " +
            "  gpuline=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1); " +
            "  if [ -n \"$gpuline\" ]; then " +
            "    gu=$(echo \"$gpuline\" | awk -F', ' '{print $1+0}'); " +
            "    used=$(echo \"$gpuline\" | awk -F', ' '{print $2+0}'); " +
            "    total=$(echo \"$gpuline\" | awk -F', ' '{print $3+0}'); " +
            "    gm=$(echo \"$used $total\" | awk '{print ($2>0)?int($1/$2*100):0}'); " +
            "    echo \"CPU:${cpu}|RAM:${ram}|GPU_UTIL:${gu}|GPU_MEM:${gm}\"; " +
            "  else " +
            "    echo \"CPU:${cpu}|RAM:${ram}|GPU_UTIL:N/A|GPU_MEM:N/A\"; " +
            "  fi; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split("|")
                for (const part of parts) {
                    const idx = part.indexOf(":")
                    if (idx < 0) continue
                    const key = part.substring(0, idx).trim()
                    const val = part.substring(idx + 1).trim()
                    if      (key === "CPU")      barRoot.cpuVal  = val + "%"
                    else if (key === "RAM")      barRoot.ramVal  = val + "%"
                    else if (key === "GPU_UTIL") barRoot.gpuUtil = val === "N/A" ? "N/A" : val + "%"
                    else if (key === "GPU_MEM")  barRoot.gpuMem  = val === "N/A" ? "N/A" : val + "%"
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#1a1b26"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 0

            // ── LEFT: App menu + Power ──────────────────────────────────
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: appMenuBtn
                    width: 28; height: 28
                    radius: 6
                    color: appMenuMa.containsMouse ? "#2a2b3d" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "󰀻"
                        color: "#bb9af7"
                        font.pixelSize: 16
                    }
                    MouseArea {
                        id: appMenuMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barRoot.toggleAppMenuRequested()
                    }
                }

                Rectangle {
                    id: powerMenuBtn
                    width: 28; height: 28
                    radius: 6
                    color: powerMenuMa.containsMouse ? "#2a2b3d" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        color: "#f7768e"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: powerMenuMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barRoot.togglePowerMenuRequested()
                    }
                }
            }

            // ── LEFT FILL ───────────────────────────────────────────────
            Item { Layout.fillWidth: true }

            // ── CENTER: Clock ───────────────────────────────────────────
            Item {
                id: clockItem
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: clockText.implicitWidth + 20
                implicitHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: clockMa.containsMouse ? "#2a2b3d" : "transparent"
                }
                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: barRoot.clockTime
                    color: "#c0caf5"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                }
                MouseArea {
                    id: clockMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barRoot.toggleCalendarRequested()
                }
            }

            // ── RIGHT FILL ──────────────────────────────────────────────
            Item { Layout.fillWidth: true }

            // ── RIGHT: System stats ─────────────────────────────────────
            Row {
                spacing: 14
                Layout.alignment: Qt.AlignVCenter

                Item {
                    id: cpuItem
                    implicitWidth: cpuRow.implicitWidth + 12
                    implicitHeight: 28
                    Rectangle {
                        anchors.fill: parent; radius: 6
                        color: cpuMa.containsMouse ? "#2a2b3d" : "transparent"
                    }
                    Row {
                        id: cpuRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "CPU"; color: "#7aa2f7"; font.pixelSize: 12; font.bold: true }
                        Text { text: barRoot.cpuVal; color: "#c0caf5"; font.pixelSize: 12; font.family: "monospace" }
                    }
                    MouseArea {
                        id: cpuMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barRoot.toggleCpuDetailsRequested()
                    }
                }

                Item {
                    id: ramItem
                    implicitWidth: ramRow.implicitWidth + 12
                    implicitHeight: 28
                    Rectangle {
                        anchors.fill: parent; radius: 6
                        color: ramMa.containsMouse ? "#2a2b3d" : "transparent"
                    }
                    Row {
                        id: ramRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "RAM"; color: "#9ece6a"; font.pixelSize: 12; font.bold: true }
                        Text { text: barRoot.ramVal; color: "#c0caf5"; font.pixelSize: 12; font.family: "monospace" }
                    }
                    MouseArea {
                        id: ramMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barRoot.toggleRamDetailsRequested()
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "GPU"; color: "#ff9e64"; font.pixelSize: 12; font.bold: true }
                    Text { text: barRoot.gpuUtil; color: "#c0caf5"; font.pixelSize: 12; font.family: "monospace" }
                    Text { text: "/"; color: "#414868"; font.pixelSize: 12 }
                    Text { text: barRoot.gpuMem; color: "#e0af68"; font.pixelSize: 12; font.family: "monospace" }
                }
            }
        }
    }
}
