import QtQuick
import Quickshell.Services.UPower
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 0

    property var batteryDevice: {
        for (let i = 0; i < UPower.devices.length; i++) {
            const dev = UPower.devices[i];
            if (dev.type === UPowerDeviceType.Battery) {
                return dev;
            }
        }
        return UPower.displayDevice;
    }

    // Determine if percentage is 0-1 or 0-100
    // If it's 0.98, we want 98. If it's 98, we want 98.
    readonly property real displayPercentage: batteryDevice.percentage <= 1.0 ? batteryDevice.percentage * 100 : batteryDevice.percentage

    Text {
        Layout.alignment: Qt.AlignHCenter
        font.family: materialIcons.name
        font.pixelSize: 18
        color: {
            if (batteryDevice.state === UPowerDeviceState.Charging || batteryDevice.state === UPowerDeviceState.FullyCharged) return "#a6e3a1";
            if (displayPercentage < 20) return "#f7768e";
            return "white";
        }
        text: {
            if (batteryDevice.state === UPowerDeviceState.Charging) return "\ue1a3";
            if (displayPercentage < 15) return "\ue19c";
            return "\ue1a4";
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Math.round(displayPercentage) + "%"
        font.pixelSize: 10
        font.weight: Font.Bold
        color: "white"
        visible: batteryDevice.percentage >= 0
    }
}
