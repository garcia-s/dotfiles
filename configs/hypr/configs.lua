
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false
        },
        tablet = {
            output = 2,
            left_handed = true,
            relative_input = false
        },
        sensitivity = 0
    },
    general = {
        gaps_in = 5,
        gaps_out = 8,
        border_size = 3,
        layout = "dwindle",
        allow_tearing = false,
        col = {
            active_border = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)"
        }
    },

    decoration = {
        rounding = 6,
    },
    animations = {
        enabled = true
    },
    dwindle = {
        preserve_split = true
    },
    misc = {
        force_default_wallpaper = -1
    }
})
