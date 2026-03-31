import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "services"

ShellRoot {

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    AppsService {
        id: appsService
    }

    Variants {
        model: Quickshell.screens
        Bar {
            property var modelData
            screen: modelData
            appsService: appsService
        }
    }
}
