hl.window_rule({
    match = { class = "xdg-desktop-portal-gtk" },
    float = true
})

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    content = "video",
    keep_aspect_ratio = true,
})


hl.window_rule({
    match = { title = "Android Emulator.*" },
    pseudo = true,
    tile = true,
    keep_aspect_ratio = true,
})
