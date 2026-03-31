import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property var allApps: []
    property bool loading: true

    Component.onCompleted: {
        refreshApps();
    }

    function refreshApps() {
        loading = true;
        discoveryProcess.running = true;
    }

    Process {
        id: discoveryProcess
        
        // Use an absolute path derived from the config directory
        command: ["python3", Quickshell.configPath + "/services/get_apps.py"]
        running: false
        
        stdout: StdioCollector { id: outputCollector }
        stderr: StdioCollector { id: errorCollector }
        
        onExited: {
            if (exitCode === 0 && outputCollector.text) {
                try {
                    var data = JSON.parse(outputCollector.text);
                    if (Array.isArray(data) && data.length > 0) {
                        root.allApps = data;
                    } else {
                        // Fallback if script returned empty array
                        root.allApps = [{name: "No apps found", exec: "", icon: "error"}];
                    }
                } catch (e) {
                    root.allApps = [{name: "Parse Error", exec: "", icon: "error"}];
                }
            } else {
                // If the process failed, show an error entry
                root.allApps = [{name: "Discovery Failed (Exit " + exitCode + ")", exec: "", icon: "error"}];
            }
            root.loading = false;
        }
    }
}
