import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property bool isOpen: false
    property var screen: null
    property var appsService: null
    signal requestClose

    property string searchText: ""
    property var filteredApps: []
    property int selectedIndex: 0

    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    onSearchTextChanged: {
        filterApps();
        selectedIndex = 0;
    }

    // React to changes in the underlying app list
    Connections {
        target: appsService
        function onAllAppsChanged() {
            filterApps();
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            filterApps();
            focusTimer.start();
        }
    }

    function filterApps() {
        if (!appsService)
            return;

        var allApps = appsService.allApps;
        if (searchText.trim() === "") {
            filteredApps = allApps;
        } else {
            var search = searchText.toLowerCase();
            var result = [];
            for (var i = 0; i < allApps.length; i++) {
                if (allApps[i].name.toLowerCase().includes(search)) {
                    result.push(allApps[i]);
                }
            }
            filteredApps = result;
        }
    }

    function launch(exec) {
        var cleanExec = exec.replace(/%[a-zA-Z]/g, "").trim();
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cleanExec + ' &"] }', root);
        proc.run();
        root.requestClose();
        searchText = "";
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceActiveFocus()
    }

    RoundedPanel {
        id: panel
        anchors: {
            left: true;
        }
        isOpen: root.isOpen
        screen: root.screen
        width: 450
        height: root.screen ? root.screen.height * 0.6 : 600
        focusable: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 25

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
                                    root.launch(filteredApps[selectedIndex].exec);
                                }
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
                            visible: !searchInput.text && !searchInput.activeFocus
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
                cellWidth: 100
                cellHeight: 110
                currentIndex: root.selectedIndex

                delegate: Item {
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        color: (root.selectedIndex === index || gridMouseArea.containsMouse) ? "#33ffffff" : "#22232e"
                        radius: 15
                        border.color: (root.selectedIndex === index || gridMouseArea.containsMouse) ? "#bd93f9" : "transparent"
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            width: parent.width - 10

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 45
                                height: 45
                                color: "#1a1b26"
                                radius: 10

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
                                root.selectedIndex = index;
                                root.launch(modelData.exec);
                            }
                        }
                    }
                }
            }
        }
    }
}
