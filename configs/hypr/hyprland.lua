-- Do I even need monitor configs in this new lua thing?
-- Seems to be working fine without the def



hl.bind("SUPER + R", hl.dsp.exec_cmd('qs ipc call panels toggle "apps"'))

-- TODO: Don't work, I don't think I actually have an ipc handler for these
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd('qs ipc call togglePowerMenu toggle'))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd('qs ipc call toggleCalendar toggle'))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd('qs ipc call toggleRamDetails toggle'))

-- Audio 
hl.bind("XF86AudioMute", hl.dsp.exec_cmd('pactl set-sink-mute @DEFAULT_SINK@ toggle'))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd('pactl set-sink-volume @DEFAULT_SINK@ -1000'))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd('pactl set-sink-volume @DEFAULT_SINK@ +1000'))

