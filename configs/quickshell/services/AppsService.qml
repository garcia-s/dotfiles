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
        // Improved shell command to find and parse desktop files
        var cmd = "find /usr/share/applications -name '*.desktop' -maxdepth 1 | xargs grep -hE '^(Name|Exec|Icon)=' | awk -F= '{ if($1==\"Name\") name=$2; else if($1==\"Exec\") exec=$2; else if($1==\"Icon\") { icon=$2; print name\"|\"exec\"|\"icon; name=\"\"; exec=\"\"; icon=\"\" } }' | sort -u";

        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }', root);
        proc.onExited.connect(function () {
            var lines = proc.stdout.trim().split("\n");
            var apps = [];
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split("|");
                if (parts.length >= 2) {
                    apps.push({
                        name: parts[0],
                        exec: parts[1],
                        icon: parts[2] || "application-x-executable"
                    });
                }
            }
            root.allApps = apps;
            loading = false;
        });
        proc.run();
    }
}
