import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "services"

ShellRoot {
    id: qs

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    property var bars: []

    function toggleApps() {
        for (var i = 0; i < bars.length; i++) {
            bars[i].togglePanel("apps");
        }
    }

    function toggleSound() {
        for (var i = 0; i < bars.length; i++) {
            bars[i].togglePanel("sound");
        }
    }

    Variants {
        model: Quickshell.screens
        Bar {
            id: bar
            property var modelData
            screen: modelData

            Component.onCompleted: {
                bars.push(bar);
            }

            Component.onDestruction: {
                var index = bars.indexOf(bar);
                if (index !== -1)
                    bars.splice(index, 1);
            }
        }
    }
}
