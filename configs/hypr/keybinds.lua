local mainMod = "SUPER"
local terminal = "kitty"
local qs = "qs ipc call"

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(qs .. ' panels toggle "apps"'))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd(qs .. ' togglePowerMenu toggle'))
hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd(qs .. ' toggleCalendar toggle'))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(qs .. ' toggleCpuDetails toggle'))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(qs .. ' toggleRamDetails toggle'))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd('pactl set-sink-mute @DEFAULT_SINK@ toggle'))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd('pactl set-sink-volume @DEFAULT_SINK@ -1000'))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd('pactl set-sink-volume @DEFAULT_SINK@ +1000'))

hl.bind("Print", hl.dsp.exec_cmd('pkill -x slurp || grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("loginctl lock-session"))


--- Shit got interesting
--- TODO: Find a way to make that pinned fullscreen functionality you used to love
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = 1, client = 1 }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(0))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("pkill -x quickshell || quickshell"))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "d" }))

-- Workspaces
for i = 1, 6 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock & systemctl suspend"), { locked = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
