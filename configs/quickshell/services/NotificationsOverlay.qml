import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../modules"

Scope {
    id: root
    property var screen

    NotificationServer {
        id: server
        keepOnReload: true
        onNotification: notif => {
            notif.tracked = true;
        }
    }

    PanelWindow {
        screen: root.screen
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        focusable: false

        anchors {
            top: true
            right: true
            bottom: true
        }

        implicitWidth: 380

        mask: Region {
            item: notifColumn
        }

        Column {
            id: notifColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 20
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Item {
                    id: card
                    required property var modelData

                    width: parent.width
                    height: cardRect.height

                    // Slide in from right
                    x: parent.width
                    Component.onCompleted: x = 0
                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    Timer {
                        interval: card.modelData.expireTimeout > 0
                                  ? card.modelData.expireTimeout * 1000
                                  : 5000
                        running: true
                        onTriggered: card.modelData.expire()
                    }

                    Rectangle {
                        id: cardRect
                        width: parent.width
                        height: cardLayout.implicitHeight + 32
                        color: "#1a1b26"
                        topLeftRadius: 16
                        bottomLeftRadius: 16

                        // Urgency accent
                        Rectangle {
                            width: 3
                            height: parent.height - 24
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            radius: 2
                            color: card.modelData.urgency === NotificationUrgency.Critical ? "#ff9e64"
                                 : card.modelData.urgency === NotificationUrgency.Low      ? "#565f89"
                                 : "#7aa2f7"
                        }

                        ColumnLayout {
                            id: cardLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 26
                                rightMargin: 16
                                topMargin: 14
                            }
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: card.modelData.appName
                                    color: "#565f89"
                                    font.pixelSize: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "\ue5cd"
                                    font.family: materialIcons.name
                                    font.pixelSize: 16
                                    color: "#565f89"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: card.modelData.dismiss()
                                    }
                                }
                            }

                            Text {
                                text: card.modelData.summary
                                color: "#c0caf5"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                textFormat: Text.PlainText
                            }

                            Text {
                                text: card.modelData.body
                                color: "#a9b1d6"
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                textFormat: Text.PlainText
                                visible: text !== ""
                                bottomPadding: 4
                            }
                        }
                    }
                }
            }
        }
    }
}
