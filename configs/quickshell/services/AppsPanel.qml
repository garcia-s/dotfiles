import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"

Item {
    id: root
    property bool isOpen: false
    property var screen: null
    signal requestClose

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

    onIsOpenChanged: {
        if (isOpen) {
            focusTimer.start();
        }
    }
    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceActiveFocus()
    }

    RoundedPanel {
        id: panel
        screen: root.screen
        isOpen: root.isOpen
        margins.top: 80
        width: 500
        height: root.screen ? root.screen.height * 0.6 : 600
        focusable: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 2

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
                                root.requestClose();
                                searchText = "";
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                root.requestClose();
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

                        Text {
                            text: "Search applications..."
                            color: "white"
                            opacity: 0.3
                            font.pixelSize: 18
                        }
                    }
                }
            }

            // Apps Grid
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

                            // Quickshell IconImage widget for themed icons
                            IconImage {
                                Layout.alignment: Qt.AlignHCenter
                                width: 48
                                height: 48
                                source: Quickshell.iconPath(modelData.icon || "application-x-executable")

                                // Fallback for Material Icon if no system icon found
                                Text {
                                    anchors.centerIn: parent
                                    text: "\ue8b5"
                                    font.family: materialIcons.name
                                    font.pixelSize: 28
                                    color: "white"
                                }
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
                                root.requestClose();
                                root.searchText = "";
                            }
                        }
                    }
                }
            }
        }
    }
}
