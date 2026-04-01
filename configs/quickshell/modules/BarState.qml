import QtQuick

QtObject {
    id: root

    property string activePanel: ""
    function toggle(panel) {
        activePanel = activePanel === panel ? "" : panel;
        console.log('Current', activePanel)
    }

    function open(panel) {
        activePanel = panel;
    }

    function close() {
        activePanel = "";
    }
}
