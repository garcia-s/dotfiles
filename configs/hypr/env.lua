
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("WRL_NO_HARDWARE_CURSOR", "1")
hl.env("XCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hyprctl setcursor default 22")
end)

