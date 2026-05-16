import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../components"
import "../modules"

Item {
    id: root

    property var screen

    anchors {
        top: parent.top
        left: parent.left
        leftMargin: 40
        topMargin: 220
    }

    clip: true
    height: 480
    width: ShellState.getActivePanel(screen.name) === "network" ? 320 : 0

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    property bool wifiEnabled: false
    property var networks: []
    property var selectedNetwork: null
    property string password: ""
    property bool connecting: false
    property string statusMessage: ""

    // --- Processes ---

    Process {
        id: checkWifiProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { id: checkWifiOut }
        onExited: (exitCode, exitStatus) => {
            root.wifiEnabled = checkWifiOut.text.trim() === "enabled";
            if (root.wifiEnabled && root.visible) {
                listNetworksProc.running = true;
            }
        }
    }

    Process {
        id: toggleWifiProc
        command: ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"]
        onExited: (exitCode, exitStatus) => checkWifiProc.running = true
    }

    Process {
        id: listNetworksProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        stdout: StdioCollector { id: listNetworksOut }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                let lines = listNetworksOut.text.split('\n');
                let nets = [];
                for (let line of lines) {
                    if (!line.trim()) continue;
                    let parts = line.split(':');
                    if (parts.length < 4) continue;
                    
                    let ssid = parts[1];
                    if (!ssid) continue;

                    nets.push({
                        inUse: parts[0] === '*',
                        ssid: ssid,
                        signal: parseInt(parts[2]),
                        security: parts[3],
                        secured: parts[3] !== "" && parts[3] !== "--"
                    });
                }
                nets.sort((a, b) => {
                    if (a.inUse) return -1;
                    if (b.inUse) return 1;
                    return b.signal - a.signal;
                });
                root.networks = nets;
            }
        }
    }

    Process {
        id: connectProc
        property string targetSsid: ""
        property string targetPass: ""
        
        stdout: StdioCollector { id: connectOut }
        stderr: StdioCollector { id: connectErr }

        function connect(ssid, pass) {
            targetSsid = ssid;
            targetPass = pass;
            root.connecting = true;
            root.statusMessage = "Connecting to " + ssid + "...";
            
            if (pass) {
                command = ["nmcli", "dev", "wifi", "connect", ssid, "password", pass];
            } else {
                command = ["nmcli", "dev", "wifi", "connect", ssid];
            }
            running = true;
        }

        onExited: (exitCode, exitStatus) => {
            root.connecting = false;
            if (exitCode === 0) {
                root.statusMessage = "Connected successfully!";
                root.selectedNetwork = null;
                root.password = "";
                listNetworksProc.running = true;
            } else {
                root.statusMessage = "Failed: " + connectErr.text.split('\n')[0];
            }
        }
    }

    // --- Logic ---

    onVisibleChanged: {
        if (visible) {
            checkWifiProc.running = true;
            statusMessage = "";
        }
    }

    Timer {
        interval: 10000
        running: root.visible && root.wifiEnabled && !root.connecting
        repeat: true
        onTriggered: listNetworksProc.running = true
    }

    Panel {
        radius: 30

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            RowLayout {
                Text {
                    text: "Network"
                    color: "white"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 44
                    height: 22
                    radius: 11
                    color: root.wifiEnabled ? "#bb9af7" : "#3b4261"

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "white"
                        x: root.wifiEnabled ? 24 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: toggleWifiProc.running = true
                    }
                }
            }

            Text {
                visible: root.statusMessage !== ""
                text: root.statusMessage
                color: root.statusMessage.includes("Failed") ? "#f7768e" : "#a6e3a1"
                font.pixelSize: 11
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                visible: root.selectedNetwork !== null
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Connect to " + (root.selectedNetwork ? root.selectedNetwork.ssid : "")
                    color: "white"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#24283b"
                    radius: 8
                    border.color: passInput.activeFocus ? "#bb9af7" : "#3b4261"
                    border.width: 1
                    visible: root.selectedNetwork && root.selectedNetwork.secured

                    TextInput {
                        id: passInput
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "white"
                        font.pixelSize: 14
                        echoMode: TextInput.Password
                        text: root.password
                        onTextChanged: root.password = text
                        
                        Text {
                            text: "Password..."
                            color: "white"
                            opacity: 0.3
                            visible: parent.text === ""
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    spacing: 10
                    
                    // Cancel Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: cancelArea.containsMouse ? "#3b4261" : "#24283b"
                        border.color: "#3b4261"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: "white"
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.selectedNetwork = null;
                                root.password = "";
                            }
                        }
                    }

                    // Connect Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 8
                        color: connectArea.containsMouse ? "#c0caf5" : "#bb9af7"
                        opacity: root.connecting ? 0.6 : 1.0
                        Text {
                            anchors.centerIn: parent
                            text: root.connecting ? "..." : "Connect"
                            color: "#1a1b26"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: connectArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !root.connecting
                            onClicked: {
                                if (root.selectedNetwork) {
                                    connectProc.connect(root.selectedNetwork.ssid, root.password);
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: netList
                visible: root.selectedNetwork === null && root.wifiEnabled
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.networks
                spacing: 8

                delegate: Rectangle {
                    width: netList.width
                    height: 50
                    radius: 12
                    color: modelData.inUse ? "#33bb9af7" : (netMouseArea.containsMouse ? "#1affffff" : "#24283b")
                    border.color: modelData.inUse ? "#bb9af7" : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Text {
                            text: modelData.secured ? "\ue198" : "\ue63e"
                            font.family: materialIcons.name
                            font.pixelSize: 20
                            color: modelData.inUse ? "#bb9af7" : "white"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: modelData.ssid
                                color: "white"
                                font.pixelSize: 13
                                font.weight: modelData.inUse ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.inUse ? "Connected" : (modelData.secured ? "Secured" : "Open")
                                color: "#bb9af7"
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            text: modelData.signal + "%"
                            color: "white"
                            font.pixelSize: 11
                            opacity: 0.6
                        }
                    }

                    MouseArea {
                        id: netMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.inUse) return;
                            root.selectedNetwork = modelData;
                            root.statusMessage = "";
                        }
                    }
                }
            }

            Text {
                visible: root.selectedNetwork === null && root.wifiEnabled && root.networks.length === 0
                text: "Scanning for networks..."
                color: "white"
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }

            Text {
                visible: !root.wifiEnabled
                text: "WiFi is turned off"
                color: "white"
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }
        }
    }
}
