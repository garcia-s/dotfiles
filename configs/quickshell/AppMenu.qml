import Quickshell
import QtQuick
import QtQuick.Layouts

// PanelWindow (not PopupWindow) — required for keyboard input.
// Positioned just below the bar's left side via margins.
PanelWindow {
    id: appRoot
    anchors {
        top: true
        left: true
    }
    margins {
        top: -10
        left: 10
    }   // 56 = bar exclusiveZone, flush with bar bottom
    exclusiveZone: 0
    visible: false
    focusable: true
    implicitWidth: 500
    implicitHeight: 560
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            appGrid.currentIndex = -1;
            searchField.forceActiveFocus();
        }
    }

    property var filteredApps: []

    function updateFilter() {
        const q = searchField.text.trim().toLowerCase();
        const all = [...DesktopEntries.applications.values];
        filteredApps = q === "" ? all : all.filter(e => e.name && e.name.toLowerCase().includes(q));
        appGrid.currentIndex = filteredApps.length > 0 ? 0 : -1;
    }

    Component.onCompleted: updateFilter()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            appRoot.updateFilter();
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
            anchors.margins: 14
            spacing: 10

            // ── Search field ─────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: "#24253a"
                border.color: searchField.activeFocus ? "#7aa2f7" : "#414868"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\ue8b6"
                        font.family: "Material Icons"
                        color: searchField.activeFocus ? "#7aa2f7" : "#565f89"
                        font.pixelSize: 18
                    }

                    TextInput {
                        id: searchField
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36
                        color: "#c0caf5"
                        font.pixelSize: 14
                        clip: true
                        focus: true

                        onTextChanged: appRoot.updateFilter()

                        // Down arrow hands off to the grid
                        Keys.onDownPressed: {
                            if (appGrid.count > 0) {
                                appGrid.currentIndex = 0;
                                appGrid.forceActiveFocus();
                            }
                        }
                        Keys.onReturnPressed: {
                            if (appGrid.currentIndex >= 0) {
                                appRoot.filteredApps[appGrid.currentIndex].execute();
                                appRoot.visible = false;
                            }
                        }
                        Keys.onEscapePressed: appRoot.visible = false
                    }
                }

                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 36
                    }
                    text: "Search applications..."
                    color: "#414868"
                    font.pixelSize: 14
                    visible: searchField.text.length === 0 && !searchField.activeFocus
                }
            }

            // ── App grid (2 columns) ─────────────────────────────────────
            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                cellWidth: Math.floor(width / 2)
                cellHeight: 64

                model: appRoot.filteredApps
                keyNavigationEnabled: true
                keyNavigationWraps: true

                // Return key / Escape while grid is focused
                Keys.onReturnPressed: {
                    if (currentIndex >= 0 && currentIndex < count) {
                        appRoot.filteredApps[currentIndex].execute();
                        appRoot.visible = false;
                    }
                }
                Keys.onEscapePressed: appRoot.visible = false

                // Up from top row returns focus to search field
                Keys.onUpPressed: {
                    if (currentIndex < cellWidth / appGrid.cellWidth) {
                        searchField.forceActiveFocus();
                    } else {
                        moveCurrentIndexUp();
                    }
                }

                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlight: Rectangle {
                    width: appGrid.cellWidth - 6
                    height: appGrid.cellHeight - 6
                    radius: 8
                    color: "#2a2b3d"
                    z: 0
                }

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: appGrid.cellWidth
                    height: appGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 8
                        color: itemMa.containsMouse && appGrid.currentIndex !== index ? "#1e1f2e" : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 36
                                height: 36
                                source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 48
                                text: modelData.name ?? ""
                                color: "#c0caf5"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: itemMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.execute();
                                appRoot.visible = false;
                            }
                            onEntered: appGrid.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
