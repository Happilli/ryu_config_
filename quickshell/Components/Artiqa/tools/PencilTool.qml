import QtQuick

QtObject {
    id: pencilTool

    property var canvas: null

    function handlePress(mouse) {
        if (!canvas)
            return;
        canvas.startStroke(mouse.x, mouse.y);
    }

    function handleMove(mouse) {
        if (!canvas)
            return;
        canvas.addPoint(mouse.x, mouse.y);
    }

    function handleRelease(mouse) {
        if (!canvas)
            return;
        canvas.finishStroke();
    }
}
