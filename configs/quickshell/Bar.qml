import Quickshell.Services.SystemTray
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import "components"
import "services"
import "modules"

Scope {
    id: root
    property var modelData

    PanelWindow {
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        screen: root.modelData
        color: "transparent"
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        mask: Region {
            item: overlay_rect
        }

        Rectangle {
            id: overlay_rect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: ShellState.showOverlay(modelData.name) ? parent.width : 0
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: ShellState.closePanel()
            }
        }
    }

    PanelWindow {
        id: panelsWindow
        exclusionMode: ExclusionMode.Ignore
        screen: root.modelData
        WlrLayershell.keyboardFocus: ShellState.getActivePanel(root.modelData.name) !== "" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        mask: Region {
            Region {
                item: soundPanel
            }
            Region {
                item: appsPanel
            }
            Region {
                item: calendarPanel
            }
            Region {
                item: powerPanel
            }
            Region {
                item: trayContextPanel
            }
            Region {
                item: underlay_rect
            }
        }
        Rectangle {
            id: underlay_rect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: ShellState.showUnderlay(modelData.name) != "" ? parent.width : 0
            color: "#00000000"
            MouseArea {
                anchors.fill: parent
                onClicked: ShellState.closePanel()
            }
        }
        SoundPanel {
            id: soundPanel
            screen: root.modelData
        }
        AppsPanel {
            id: appsPanel
            screen: root.modelData
        }
        PowerPanel {
            id: powerPanel
            screen: root.modelData
        }
        CalendarPanel {
            id: calendarPanel
            screen: root.modelData
        }
        TrayContextPanel {
            id: trayContextPanel
            screen: root.modelData
        }
    }

    PanelWindow {
        id: bar
        screen: root.modelData
        exclusiveZone: 40
        implicitWidth: 40
        anchors {
            top: true
            left: true
            bottom: true
        }

        color: "transparent"

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height - 60
            color: "transparent"

            InvertedCorner {
                location: 3
                radius: 25
                color: "#1a1b26"
                anchors.bottom: parent.top
                anchors.left: parent.left
            }

            InvertedCorner {
                location: 1
                radius: 25
                color: "#1a1b26"
                anchors.top: parent.bottom
                anchors.left: parent.left
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                width: 40
                color: "#1a1b26"
                topRightRadius: 25
                bottomRightRadius: 25

                ColumnLayout {
                    id: buttons
                    anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    spacing: 5
                    width: parent.width

                    Button {
                        id: appsButton
                        icon: "\ue5c3"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: ShellState.togglePanel("apps")
                    }
                    Button {
                        icon: "\ue8ac"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: ShellState.togglePanel("power")
                    }
                    Workspaces {}

                    Rectangle {
                        width: 28
                        height: 80
                        color: "#111"
                        radius: 20
                        Layout.alignment: Qt.AlignHCenter
                        ColumnLayout {
                            anchors.fill: parent
                            RoundedButton {
                                icon: "\ue04d"
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: ShellState.togglePanel("sound")
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
                        onClicked: ShellState.togglePanel("calendar")
                    }
                }
            }
        }
    }
}
