import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    property bool isOpen: false
    property var radius: 40
    default property alias content: container.data
    color: "transparent"
    visible: root.isOpen
    exclusiveZone: -10000000
    focusable: true

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
        anchors.leftMargin: root.isOpen ? 0 : -root.width

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutQuint
            }
        }

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
