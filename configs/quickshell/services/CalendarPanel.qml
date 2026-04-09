import Quickshell
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
    height: 380
    width: ShellState.getActivePanel(screen.name) === "calendar" ? 354 : 0

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    property var today: new Date()
    property int viewMonth: today.getMonth()
    property int viewYear: today.getFullYear()

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property int cellSize: 46

    Connections {
        target: ShellState
        function onExclusivePanelChanged() {
            if (ShellState.getActivePanel(screen.name) === "calendar") {
                var now = new Date();
                root.today = now;
                root.viewMonth = now.getMonth();
                root.viewYear = now.getFullYear();
            }
        }
    }

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(month, year) {
        var d = new Date(year, month, 1).getDay();
        return (d + 6) % 7; // Monday = 0
    }

    Panel {
        radius: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8

            // Month navigation header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "\ue5cb"
                    font.family: materialIcons.name
                    font.pixelSize: 26
                    color: "#c0caf5"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.viewMonth === 0) {
                                root.viewMonth = 11;
                                root.viewYear -= 1;
                            } else {
                                root.viewMonth -= 1;
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.monthNames[root.viewMonth] + " " + root.viewYear
                    color: "#c0caf5"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "\ue5cc"
                    font.family: materialIcons.name
                    font.pixelSize: 26
                    color: "#c0caf5"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.viewMonth === 11) {
                                root.viewMonth = 0;
                                root.viewYear += 1;
                            } else {
                                root.viewMonth += 1;
                            }
                        }
                    }
                }
            }

            // Day-of-week headers
            Row {
                Layout.fillWidth: true
                Repeater {
                    model: ["M", "T", "W", "T", "F", "S", "S"]
                    Text {
                        width: root.cellSize
                        text: modelData
                        color: "#565f89"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Days grid
            Grid {
                columns: 7

                // Offset empty cells for first weekday
                Repeater {
                    model: root.firstDayOfMonth(root.viewMonth, root.viewYear)
                    Item {
                        width: root.cellSize
                        height: root.cellSize
                    }
                }

                Repeater {
                    model: root.daysInMonth(root.viewMonth, root.viewYear)
                    delegate: Item {
                        width: root.cellSize
                        height: root.cellSize

                        readonly property bool isToday: (index + 1) === root.today.getDate() &&
                                                        root.viewMonth === root.today.getMonth() &&
                                                        root.viewYear === root.today.getFullYear()

                        Rectangle {
                            anchors.centerIn: parent
                            width: 36
                            height: 36
                            radius: 18
                            color: isToday ? "#bb9af7" : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: isToday ? "#1a1b26" : "#c0caf5"
                            font.pixelSize: 14
                            font.weight: isToday ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
