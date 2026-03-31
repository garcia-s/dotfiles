import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property int radius: 30
    property bool isOpen: false
    property color color: "#1a1b26"
    property var screen: null

    width: 300
    height: 500

    default property alias content: container.data

    PanelWindow {
        id: win
        screen: root.screen

        anchors {
            top: true
            bottom: true
            left: true
        }

        width: root.width
        color: "transparent"
        visible: root.isOpen
        exclusiveZone: 0

        Item {
            id: flyout
            anchors.fill: parent

            // Slide animation
            x: root.isOpen ? 0 : -root.width

            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: body
                width: root.width
                height: root.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: root.color
                topRightRadius: root.radius
                bottomRightRadius: root.radius

                Item {
                    id: container
                    anchors.fill: parent
                    clip: true
                }
            }

            InvertedCorner {
                location: 3 // Top junction
                radius: root.radius
                color: root.color
                anchors.bottom: body.top
                anchors.left: body.left
            }

            InvertedCorner {
                location: 1 // Bottom junction
                radius: root.radius
                color: root.color
                anchors.top: body.bottom
                anchors.left: body.left
            }
        }
    }
}
