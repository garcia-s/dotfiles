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
    property BarState state: BarState {}

    Component.onCompleted: Visibilities.register(modelData.name, state)
    Component.onDestruction: Visibilities.unregister(modelData.name)

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
                    onClicked: root.state.toggle("apps")
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
                            onClicked: root.state.toggle("sound")
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

    PanelWindow {
        id: panelsWindow
        screen: root.modelData
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        WlrLayershell.keyboardFocus: root.state.activePanel !== "" ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        mask: Region {
            item: {
                if (state.activePanel == "sound")
                    return soundPanel;
                if (state.activePanel == "apps")
                    return appsPanel;
            }
        }

        SoundPanel {
            id: panelsContainer
            state: root.state
        }
        AppsPanel {
            id: appsPanel
            state: root.state
        }
    }
}
