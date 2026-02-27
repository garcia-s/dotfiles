import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: ramRoot

    width: 270
    height: 310
    color: "transparent"

    property int totalRamMb: 1
    property bool clearNext: false

    ListModel { id: procModel }

    // On-demand: only runs while popup is visible, refreshes every 3s
    Process {
        id: ramProc
        running: ramRoot.visible
        command: ["/home/symmetry/.local/bin/qs-sysmon", "ram"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "---") {
                    ramRoot.clearNext = true
                    return
                }
                if (line.startsWith("TOTAL:")) {
                    ramRoot.totalRamMb = parseInt(line.substring(6)) || 1
                    return
                }
                if (ramRoot.clearNext) {
                    procModel.clear()
                    ramRoot.clearNext = false
                }
                const idx = line.indexOf(":")
                if (idx < 0) return
                const name = line.substring(0, idx)
                const mb   = parseInt(line.substring(idx + 1)) || 0
                procModel.append({ procName: name, usageMb: mb })
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
            spacing: 6

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Top RAM Consumers"
                color: "#9ece6a"
                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#414868"
            }

            Repeater {
                model: procModel
                delegate: RowLayout {
                    required property string procName
                    required property int usageMb
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: procName
                        color: "#c0caf5"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.preferredWidth: 100
                    }

                    // Mini progress bar
                    Rectangle {
                        width: 70
                        height: 12
                        radius: 3
                        color: "#24253a"

                        Rectangle {
                            width: Math.min(parent.width * usageMb / ramRoot.totalRamMb, parent.width)
                            height: parent.height
                            radius: 3
                            color: "#9ece6a"

                            Behavior on width {
                                NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
                            }
                        }
                    }

                    Text {
                        text: usageMb + "M"
                        color: "#e0af68"
                        font.pixelSize: 11
                        font.family: "monospace"
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 42
                    }
                }
            }

            // Placeholder when loading
            Text {
                visible: procModel.count === 0
                Layout.alignment: Qt.AlignHCenter
                text: "Loading..."
                color: "#565f89"
                font.pixelSize: 12
            }
        }
    }
}
