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
    property string activePanel: ""
    property var appsService: null

    function togglePanel(panelName) {
        if (activePanel === panelName) {
            activePanel = "";
        } else {
            activePanel = panelName;
        }
    }

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

    AppsPanel {
        id: appsPanel
        width: 300
        height: 500
        screen: mainBar.screen
        appsService: mainBar.appsService
        isOpen: activePanel === "apps"
        onRequestClose: activePanel = ""
    }

    SoundPanel {
        id: soundPanel
        screen: mainBar.screen
        isOpen: activePanel === "sound"
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
                id: appsButton
                width: 30
                height: 30
                color: activePanel === "apps" ? "#bd93f9" : "#1a1b26"
                radius: 3
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "\ue5c3"
                    color: "white"
                    font.family: materialIcons.name
                    font.pixelSize: 22
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: togglePanel("apps")
                }
            }

            // Workspace Pills

            Workspaces {}
            Rectangle {
                id: soundButton
                width: 28
                height: 80
                color: activePanel === "sound" ? "#bd93f9" : "#111"
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
                    onClicked: togglePanel("sound")
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
