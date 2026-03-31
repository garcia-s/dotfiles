import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Column {
    id: workspaceColumn
    spacing: 12
    anchors.horizontalCenter: parent.horizontalCenter

    Repeater {
        model: Hyprland.workspaces
        // Your 5 fixed pill slots

        delegate: Rectangle {
            id: pill
            width: 10
            readonly property bool isFocused: {
                if (Hyprland.focusedMonitor.activeWorkspace) {
                    return Hyprland.focusedMonitor.activeWorkspace.id === (index + 1);
                }
                return false;
            }

            radius: 10
            height: isFocused ? 30 : 10
            color: isFocused ? "#7aa2f7" : "#444b6a"

            // ... Behavior and MouseArea ...
            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
