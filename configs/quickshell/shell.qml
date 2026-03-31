import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    Variants {
        model: Quickshell.screens
        Bar {
            property var modelData
            screen: modelData
        }
    }
}
