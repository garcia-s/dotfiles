import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../components"
import "../modules"

Item {
    id: root
    property var screen

    anchors {
        bottom: parent.bottom
        left: parent.left
        leftMargin: 40
        bottomMargin: 60
    }

    clip: true

    property var activeItem: ShellState.trayContextItem

    QsMenuOpener {
        id: menuOpener
        menu: root.activeItem?.menu ?? null
    }

    property var menuItems: menuOpener.children

    property int firstSepIndex: {
        for (var i = 0; i < menuItems.length; i++) {
            if (menuItems[i].isSeparator) return i;
        }
        return -1;
    }

    height: 600

    width: ShellState.getActivePanel(screen.name) === 'tray' ? 230 : 0

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Panel {
        radius: 20

        Flickable {
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            contentHeight: itemsColumn.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: itemsColumn
                width: parent.width
                spacing: 0

                Repeater {
                    model: root.menuItems

                    delegate: Item {
                        id: itemDelegate
                        required property var modelData
                        required property int index

                        // Items before the first separator are header items
                        property bool isHeader: root.firstSepIndex > 0 && index < root.firstSepIndex
                        // The first separator becomes the styled divider
                        property bool isDivider: index === root.firstSepIndex
                        // Any other separator is a regular section separator
                        property bool isBodySep: !isHeader && !isDivider && modelData.isSeparator

                        width: itemsColumn.width
                        height: isHeader ? 36 : (isDivider ? 20 : (isBodySep ? 16 : 40))

                        // Header item (app name / title)
                        Text {
                            visible: itemDelegate.isHeader
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            text: itemDelegate.modelData.text
                            color: "#bb9af7"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        // First separator becomes a divider line
                        Rectangle {
                            visible: itemDelegate.isDivider
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            height: 1
                            color: "#565f89"
                        }

                        // Body separator line
                        Rectangle {
                            visible: itemDelegate.isBodySep
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            height: 1
                            color: "#565f89"
                            opacity: 0.5
                        }

                        // Regular menu item
                        Rectangle {
                            visible: !itemDelegate.isHeader && !itemDelegate.isDivider && !itemDelegate.isBodySep
                            anchors.fill: parent
                            color: itemMouse.containsMouse && itemDelegate.modelData.enabled ? "#2a2d3e" : "transparent"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Rectangle {
                                    visible: itemDelegate.modelData.checkState !== Qt.Unchecked
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: "#bb9af7"
                                }

                                Text {
                                    text: itemDelegate.modelData.text
                                    color: itemDelegate.modelData.enabled ? "#c0caf5" : "#565f89"
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: itemDelegate.modelData.enabled
                                onClicked: {
                                    itemDelegate.modelData.triggered();
                                    ShellState.closePanel();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
