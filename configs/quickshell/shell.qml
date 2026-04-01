import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "services"
import "modules"

ShellRoot {
    id: shell

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            id: bar
        }
    }

    IpcHandler {
        target: "panels"
        function toggle(type: string): void {
            const state = Visibilities.getForScreen(Hyprland.focusedMonitor?.name ?? "");
            if (state)
                state.toggle(type);
        }
    }

    IpcHandler {
        target: "audio"
        function increment(): void {
            const panel = shell.getCurrentPanel();
            if (panel)
                panel.togglePanel("sound");
        }

        function decrement(): void {
            const state = Visibilities.getForScreen(Hyprland.focusedMonitor?.name ?? "");
            if (state) state.toggle(type);
            {}
        }
    }
}
