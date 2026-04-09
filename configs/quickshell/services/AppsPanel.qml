import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import "../modules"

Item {
    id: root

    property var screen

    anchors {
        top: parent.top
        left: parent.left
        leftMargin: 40
        topMargin: 50
    }

    clip: true
    height: 600
    width: ShellState.getActivePanel(screen.name) === "apps" ? 600 : 0

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    property string searchText: ""
    property int selectedIndex: 0

    readonly property var filteredApps: {
        var all = DesktopEntries.applications.values;
        if (searchText.trim() === "") {
            return all;
        } else {
            var search = searchText.toLowerCase();
            return all.filter(app => app.name.toLowerCase().includes(search));
        }
    }

    onSearchTextChanged: selectedIndex = 0
    Connections {
        target: ShellState
        function onExclusivePanelChanged() {
            if (ShellState.getActivePanel(root.screen.name) === "apps") {
                searchInput.forceActiveFocus()
            } else {
                root.searchText = ""
            }
        }
    }

    Panel {
        radius: 30

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 5

            // Search Box
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#2a2b36"
                radius: 20
                border.color: searchInput.activeFocus ? "#bd93f9" : "#33ffffff"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text {
                        text: "\ue8b6"
                        font.family: materialIcons.name
                        font.pixelSize: 24
                        color: "white"
                        opacity: 0.7
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "white"
                        font.pixelSize: 18
                        text: root.searchText
                        onTextChanged: root.searchText = text

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (filteredApps.length > selectedIndex) {
                                    filteredApps[selectedIndex].execute();
                                }
                                ShellState.closePanel();
                                searchText = "";
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                ShellState.closePanel();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                selectedIndex = Math.min(filteredApps.length - 1, selectedIndex + 4);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                selectedIndex = Math.max(0, selectedIndex - 4);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Right) {
                                selectedIndex = Math.min(filteredApps.length - 1, selectedIndex + 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Left) {
                                selectedIndex = Math.max(0, selectedIndex - 1);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            GridView {
                id: appsGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.filteredApps
                cellWidth: 110
                cellHeight: 110
                currentIndex: root.selectedIndex

                delegate: Item {
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        color: (root.selectedIndex === index || gridMouseArea.containsMouse) ? "#33ffffff" : "#22232e"
                        radius: 20
                        border.color: (root.selectedIndex === index || gridMouseArea.containsMouse) ? "#bd93f9" : "transparent"
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            width: parent.width - 10

                            IconImage {
                                Layout.alignment: Qt.AlignHCenter
                                width: 48
                                height: 48
                                source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: "white"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                            }
                        }

                        MouseArea {
                            id: gridMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.execute();
                                ShellState.closePanel();
                                root.searchText = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
