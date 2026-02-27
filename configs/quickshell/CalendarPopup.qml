import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: calRoot

    width: 268
    height: 242
    color: "transparent"

    property var today: new Date()
    property int displayYear: today.getFullYear()
    property int displayMonth: today.getMonth()

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    function firstWeekday(y, m) {
        return new Date(y, m, 1).getDay()
    }

    function prevMonth() {
        if (displayMonth === 0) { displayMonth = 11; displayYear-- }
        else displayMonth--
    }

    function nextMonth() {
        if (displayMonth === 11) { displayMonth = 0; displayYear++ }
        else displayMonth++
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

            // Month / year navigation
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "<"
                    color: "#7aa2f7"
                    font.pixelSize: 14
                    font.bold: true
                    leftPadding: 4
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calRoot.prevMonth()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().standaloneMonthName(calRoot.displayMonth) + " " + calRoot.displayYear
                    color: "#c0caf5"
                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    text: ">"
                    color: "#7aa2f7"
                    font.pixelSize: 14
                    font.bold: true
                    rightPadding: 4
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calRoot.nextMonth()
                    }
                }
            }

            // Weekday headers
            Row {
                Layout.fillWidth: true
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    delegate: Text {
                        width: (268 - 24) / 7
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: "#565f89"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            // Day grid
            Grid {
                columns: 7
                columnSpacing: 0
                rowSpacing: 2
                Layout.alignment: Qt.AlignHCenter

                // Blank cells for offset
                Repeater {
                    model: calRoot.firstWeekday(calRoot.displayYear, calRoot.displayMonth)
                    delegate: Item {
                        width: (268 - 24) / 7
                        height: width
                    }
                }

                // Day cells
                Repeater {
                    model: calRoot.daysInMonth(calRoot.displayYear, calRoot.displayMonth)
                    delegate: Rectangle {
                        required property int index
                        property int day: index + 1
                        property bool isToday: (
                            calRoot.displayYear  === calRoot.today.getFullYear() &&
                            calRoot.displayMonth === calRoot.today.getMonth()    &&
                            day                  === calRoot.today.getDate()
                        )

                        width: (268 - 24) / 7
                        height: width
                        radius: width / 2
                        color: isToday ? "#bb9af7"
                             : dayMa.containsMouse ? "#2a2b3d"
                             : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: day
                            color: parent.isToday ? "#1a1b26" : "#c0caf5"
                            font.pixelSize: 11
                            font.bold: parent.isToday
                        }

                        MouseArea {
                            id: dayMa
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
