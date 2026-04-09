import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Column {
    id: trayColumn
    spacing: 5
    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            width: 30
            height: 30
            color: mouse.containsMouse ? "#313244" : "transparent"
            radius: 6

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: modelData.icon !== null ? modelData.icon : ""
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        modelData.menu.open(this);
                    } else {
                        modelData.activate();
                    }
                }
            }
        }
    }
}
