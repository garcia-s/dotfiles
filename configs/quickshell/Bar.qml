import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import "components"
import "services"

PanelWindow {
    id: bar
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Top;
        }
    }

    screen: screen
    implicitWidth: 40
    property int currentWorkspace: 1
    property string activePanel: ""

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

    AppsPanel {
        screen: bar.screen
        isOpen: activePanel == "apps"
    }

    SoundPanel {
        screen: bar.screen
        isOpen: activePanel == "sound"
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - 100
        width: 40
        color: "#1a1b26"
        topRightRadius: 20
        bottomRightRadius: 20

        ColumnLayout {
            id: buttons
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            spacing: 20
            width: parent.width

            Button {
                id: appsButton
                icon: "\ue5c3"
                Layout.alignment: Qt.AlignHCenter
                onClicked: togglePanel("apps")
            }
            Workspaces {}

            Rectangle {
                width: 28
                height: 80
                color: activePanel === "sound" ? "#bd93f9" : "#111"
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter
                    RoundedButton {
                        icon: "\ue04d"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: togglePanel("sound")
                    }
                    RoundedButton {
                        icon: "\ue1a7"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
            Tray {
                Layout.alignment: Qt.AlignHCenter
            }
            Clock {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
