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
        layout = "master",
        allow_tearing = true,
        col = {
            active_border = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)"
        }
    },
    decoration = {
        rounding = 10,
    },
    master = {
        new_status = "slave"
    }
})
