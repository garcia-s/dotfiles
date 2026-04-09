pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root
    property var exclusivePanel: string = ""
    property var screen: string = ""

    function showOverlay(screenName: string): bool {
        return screen !== screenName && screen != "" && screen != undefined;
    }

    function showUnderlay(screenName: string): bool {
        return screen == screenName;
    }

    function getActivePanel(screenName: string): string {
        return screen == screenName ? exclusivePanel : "";
    }

    function togglePanel(panel: string) {
        if (panel == "")
            return;
        if (exclusivePanel == panel) {
            screen = "";
            exclusivePanel = "";
            return;
        }

        screen = Hyprland.focusedMonitor.name;
        exclusivePanel = panel;
    }

    function closePanel() {
        screen = "";
        exclusivePanel = "";
    }
}
