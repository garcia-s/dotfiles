import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../components"
import "../modules"

Item {
    property var screen

    anchors {
        top: parent.top
        left: parent.left
        leftMargin: 40
        topMargin: 80
    }

    clip: true
    height: 512
    width: ShellState.getActivePanel(screen.name) === "power" ? 120 : 0

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    component PowerButton: Rectangle {
        id: btn
        property string icon
        property string label
        property color accent: "#7aa2f7"
        signal clicked

        width: 80
        height: 80
        Layout.alignment: Qt.AlignHCenter
        color: area.containsMouse ? Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.2) : "#22232e"
        radius: 14

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.icon
                font.family: materialIcons.name
                font.pixelSize: 22
                color: "white"
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.label
                color: "#c0caf5"
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }

    Process { id: shutdownProc;  command: ["systemctl", "poweroff"]       }
    Process { id: rebootProc;    command: ["systemctl", "reboot"]         }
    Process { id: suspendProc;   command: ["systemctl", "suspend"]        }
    Process { id: hibernateProc; command: ["systemctl", "hibernate"]      }
    Process { id: logoutProc;    command: ["hyprctl", "dispatch", "exit"] }

    Panel {
        radius: 20
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            PowerButton {
                icon: "\ue8ac"
                label: "Shutdown"
                accent: "#f7768e"
                onClicked: shutdownProc.running = true
            }
            PowerButton {
                icon: "\ue5d5"
                label: "Reboot"
                accent: "#ff9e64"
                onClicked: rebootProc.running = true
            }
            PowerButton {
                icon: "\uef44"
                label: "Suspend"
                accent: "#7aa2f7"
                onClicked: suspendProc.running = true
            }
            PowerButton {
                icon: "\ue904"
                label: "Hibernate"
                accent: "#bb9af7"
                onClicked: hibernateProc.running = true
            }
            PowerButton {
                icon: "\ue9ba"  // logout
                label: "Log out"
                accent: "#e0af68"
                onClicked: logoutProc.running = true
            }
        }
    }
}
