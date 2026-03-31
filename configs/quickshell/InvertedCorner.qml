import QtQuick

Canvas {
    id: root
    property int location: 0
    property int radius: 12
    property color color: "#1a1b26"

    onLocationChanged: requestPaint()
    onRadiusChanged: requestPaint()
    onColorChanged: requestPaint()

    width: radius
    height: radius

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = root.color;
        ctx.beginPath();

        switch (location) {
        case 0: // Top Left
            ctx.moveTo(radius, radius);
            ctx.lineTo(radius, 0);
            ctx.lineTo(0, 0);
            ctx.arcTo(radius, 0, radius, radius, radius);
            break;
        case 1: // Top Right
            ctx.moveTo(0, radius);
            ctx.lineTo(0, 0);
            ctx.lineTo(radius, 0);
            ctx.arcTo(0, 0, 0, radius, radius);
            break;
        case 2: // Bottom Left
            ctx.moveTo(radius, 0);
            ctx.lineTo(radius, radius);
            ctx.lineTo(0, radius);
            ctx.arcTo(radius, radius, radius, 0, radius);
            break;
        case 3: // Bottom Right
            ctx.moveTo(0, 0);
            ctx.lineTo(0, radius);
            ctx.lineTo(radius, radius);
            ctx.arcTo(0, radius, 0, 0, radius);
            break;
        }
        ctx.fill();
    }
}
