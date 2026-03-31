import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property bool isOpen: false
    property bool focusable: false
    property var radius: 40
    default property alias content: container.data
    color: "transparent"
    visible: root.isOpen
    exclusiveZone: 0

    anchors {
        left: true
        top: true
    }

    margins {
        top: 60
    }

    Rectangle {
        id: body
        color: "transparent"
        anchors.fill: parent

        // Main colored bar
        Rectangle {
            id: mainBarBackground
            width: parent.width
            height: parent.height - (2 * root.radius)
            anchors.centerIn: parent

            topRightRadius: root.radius
            bottomRightRadius: root.radius
            color: "#1a1b26"

            Item {
                id: container
                anchors.fill: parent
                clip: true
            }
        }

        InvertedCorner {
            location: 3
            radius: root.radius
            color: "#1a1b26"
            anchors.bottom: mainBarBackground.top
            anchors.left: parent.left
        }

        InvertedCorner {
            location: 1
            radius: root.radius
            color: "#1a1b26"
            anchors.top: mainBarBackground.bottom
            anchors.left: parent.left
        }
    }
}
