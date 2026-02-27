import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: cpuRoot

    width: 300
    height: 220
    color: "transparent"

    ListModel { id: coreModel }

    // On-demand: only runs while popup is visible
    Process {
        id: coreProc
        running: cpuRoot.visible
        command: ["/home/symmetry/.local/bin/qs-sysmon", "cpu"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "---") return
                const idx = line.indexOf(":")
                if (idx < 0) return
                const core = parseInt(line.substring(0, idx))
                const pct  = parseInt(line.substring(idx + 1))
                if (isNaN(core) || isNaN(pct)) return
                if (core >= coreModel.count) {
                    coreModel.append({ coreId: core, usage: pct })
                } else {
                    coreModel.setProperty(core, "usage", pct)
                }
            }
        }
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
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Per-Core CPU Usage"
                color: "#7aa2f7"
                font.pixelSize: 13
                font.bold: true
            }

            // Core bar grid — 4 columns
            Grid {
                columns: 4
                columnSpacing: 8
                rowSpacing: 6
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: coreModel
                    delegate: Column {
                        required property int coreId
                        required property int usage
                        spacing: 3

                        Rectangle {
                            width: 52
                            height: 68
                            radius: 4
                            color: "#24253a"

                            Rectangle {
                                id: usageBar
                                width: parent.width
                                height: parent.height * (usage / 100)
                                anchors.bottom: parent.bottom
                                radius: 4
                                color: usage > 80 ? "#f7768e"
                                     : usage > 50 ? "#ff9e64"
                                     : "#7aa2f7"

                                Behavior on height {
                                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: usage + "%"
                                color: "#c0caf5"
                                font.pixelSize: 10
                                font.family: "monospace"
                            }
                        }

                        Text {
                            width: 52
                            horizontalAlignment: Text.AlignHCenter
                            text: "C" + coreId
                            color: "#565f89"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
}
