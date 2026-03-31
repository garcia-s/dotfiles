import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "services"

ShellRoot {
    id: shell
    property var bars: ({})

    function getCurrentPanel() {
        return shell.bars[Hyprland.focusedMonitor?.name ?? ""];
    }

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            id: bar
            property var modelData
            screen: modelData

            Component.onCompleted: {
                let p = Object.assign({}, shell.bars);
                p[modelData.name] = bar;
                shell.bars = p;
            }

            Component.onDestruction: {
                let p = Object.assign({}, shell.bars);
                delete p[modelData.name];
                shell.bars = p;
            }
        }
    }

    IpcHandler {
        target: "panels"
        function toggle(type: string): void {
            const panel = shell.getCurrentPanel();
            if (panel)
                panel.togglePanel(type);
        }
    }

    IpcHandler {
        target: "audio"
        function increaseVolume(): void {
            const panel = shell.getCurrentPanel();
            if (panel)
            panel.togglePanel("sound");
           
        }
    }
}
