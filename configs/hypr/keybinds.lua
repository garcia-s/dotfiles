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



hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + p", function()
    local win = hl.dsp.window
    hl.dispatch(win.float())
    hl.dispatch(win.move({ x = -100, y = -100, relative = true }))
    hl.dispatch(win.resize({ x = 720, y = 420, }))
    hl.dispatch(win.fullscreen_state({ internal = 0, client = 3 }))
    hl.dispatch(win.pin())
end)

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("pkill -x quickshell || quickshell"))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "d" }))

-- Workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end


hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
