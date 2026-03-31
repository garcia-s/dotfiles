import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import "components"

PanelWindow {
    id: mainBar

    Component.onCompleted: {
        SystemTray.isHost = true;
        console.log("Quickshell system tray workign");
    }

    screen: screen
    implicitWidth: 40
    property int currentWorkspace: 1

    anchors {
        top: true
        left: true
        bottom: true
        right: false
    }

    color: "transparent"

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - 100
        color: "#1a1b26"
        topRightRadius: 20
        bottomRightRadius: 20

        ColumnLayout {
            id: buttons
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            spacing: 20

            Rectangle {
                id: myButton
                width: 30
                height: 30
                color: "#1a1b26"
                radius: 3
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "\ue5c3"
                    color: "white"
                    font.family: materialIcons.name // Added font family
                    font.pixelSize: 22
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Menu clicked")
                }
            }

            // Workspace Pills

            Workspaces {}
            Rectangle {
                id: different
                width: 28
                height: 80
                color: "#111"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    id: configs
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    Text {

                        text: "\ue04d"
                        color: "white"
                        font.family: materialIcons.name
                        font.pixelSize: 22
                    }
                    Text {
                        text: "\ue1a7"
                        color: "white"
                        font.family: materialIcons.name
                        font.pixelSize: 22
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Menu clicked")
                }
            }

            Item {
                Layout.fillHeight: true
            }
            Tray {
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Clock {
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
