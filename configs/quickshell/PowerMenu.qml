import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: powerRoot

    width: 220
    height: 370
    color: "transparent"

    Keys.onEscapePressed: powerRoot.visible = false

    Process {
        id: actionProc
        running: false
        onRunningChanged: if (!running) command = []
    }

    function runCmd(cmd) {
        actionProc.command = cmd
        actionProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#1a1b26"
        border.color: "#414868"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "System"
                color: "#bb9af7"
                font.pixelSize: 14
                font.bold: true
                topPadding: 6
                bottomPadding: 2
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#414868"
            }

            Repeater {
                model: [
                    { label: "Lock",      icon: "󰷛", color: "#7aa2f7", cmd: ["swaylock"] },
                    { label: "Suspend",   icon: "󰒲", color: "#9ece6a", cmd: ["systemctl", "suspend"] },
                    { label: "Hibernate", icon: "󰤄", color: "#e0af68", cmd: ["systemctl", "hibernate"] },
                    { label: "Logout",    icon: "󰍃", color: "#ff9e64", cmd: ["hyprctl", "dispatch", "exit", "0"] },
                    { label: "Reboot",    icon: "󰑓", color: "#f7768e", cmd: ["systemctl", "reboot"] },
                    { label: "Shutdown",  icon: "⏻",  color: "#db4b4b", cmd: ["systemctl", "poweroff"] }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 46
                    radius: 8
                    color: btnMa.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        spacing: 14

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.icon
                            color: modelData.color
                            font.pixelSize: 20
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: "#c0caf5"
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: btnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerRoot.visible = false
                            powerRoot.runCmd(modelData.cmd)
                        }
                    }
                }
            }
        }
    }
}
