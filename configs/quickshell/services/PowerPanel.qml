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
    height: 540
    width: ShellState.getActivePanel(screen.name) === "power" ? 120 : 0

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Process { id: shutdownProc;  command: ["systemctl", "poweroff"]       }
    Process { id: rebootProc;    command: ["systemctl", "reboot"]         }
    Process { id: suspendProc;   command: ["systemctl", "suspend"]        }
    Process { id: hibernateProc; command: ["systemctl", "hibernate"]      }
    Process { id: logoutProc;    command: ["hyprctl", "dispatch", "exit"] }

    Panel {
        radius: 30
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            PowerButton {
                icon: "\ue8ac"
                label: "Shutdown"
                onClicked: shutdownProc.running = true
            }
            PowerButton {
                icon: "\ue5d5"
                label: "Reboot"
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
                onClicked: hibernateProc.running = true
            }
            PowerButton {
                icon: "\ue9ba"  
                label: "Log out"
                onClicked: logoutProc.running = true
            }
        }
    }
}
