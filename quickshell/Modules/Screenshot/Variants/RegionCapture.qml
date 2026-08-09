pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell.Wayland
import qs.Services.Theme
import qs.Configuration.Screenshot

Item {
    id: root
    anchors.fill: parent
    focus: true
    opacity: 0

    required property var screen

    Component.onCompleted: {
        root.forceActiveFocus();
        entryAnim.start();
    }

    Keys.onEscapePressed: ScreenshotConfig.dismiss()

    property bool hasDragged: false

    property real targetX: root.hasDragged ? Math.min(dragArea.startX, dragArea.curX) : root.width / 2
    property real targetY: root.hasDragged ? Math.min(dragArea.startY, dragArea.curY) : root.height / 2
    property real targetW: root.hasDragged ? Math.abs(dragArea.curX - dragArea.startX) : 0
    property real targetH: root.hasDragged ? Math.abs(dragArea.curY - dragArea.startY) : 0

    property real selX: root.targetX
    property real selY: root.targetY
    property real selW: root.targetW
    property real selH: root.targetH

    Behavior on selX {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selY {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selW {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selH {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }

    NumberAnimation {
        id: entryAnim
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 180
        easing.type: Easing.OutCubic
    }

    ScreencopyView {
        id: screencopy
        captureSource: root.screen
        live: true
        anchors.fill: parent

        onHasContentChanged: {
            if (hasContent) {
                live = false;
            }
        }
    }

    ShaderEffectSource {
        id: cropSource
        sourceItem: screencopy
        live: true
        opacity: 0
    }

    component Overlay: Rectangle {
        color: Theme.backgroundColor
        opacity: 0.85
    }

    component Corner: Rectangle {
        width: 12
        height: 12
        radius: 6
        color: Theme.surfaceColor
        border.color: Theme.primaryColor
        border.width: 2
    }

    component Rope: Shape {
        id: ropeRoot

        required property real anchorX
        required property real anchorY
        required property real endX
        required property real endY
        property int segmentCount: 18
        property real slack: 1.25
        property real gravity: 900
        property int constraintIterations: 16

        layer.enabled: true
        layer.samples: 4
        opacity: 0.7

        ShapePath {
            strokeColor: Theme.primaryColor
            strokeWidth: 3
            fillColor: "transparent"

            PathPolyline {
                id: polyline
            }
        }

        property var points: []
        property bool initialized: false

        function resetPoints() {
            let pArray = [];
            const dx = (ropeRoot.endX - ropeRoot.anchorX) / ropeRoot.segmentCount;
            const dy = (ropeRoot.endY - ropeRoot.anchorY) / ropeRoot.segmentCount;

            for (let i = 0; i <= ropeRoot.segmentCount; i++) {
                let px = ropeRoot.anchorX + dx * i;
                let py = ropeRoot.anchorY + dy * i;
                pArray.push({
                    x: px,
                    y: py,
                    px: px,
                    py: py,
                    pinned: (i === 0 || i === ropeRoot.segmentCount)
                });
            }
            ropeRoot.points = pArray;
            ropeRoot.initialized = true;
            updateVisuals();
        }

        Component.onCompleted: resetPoints()

        function updateVisuals() {
            let pts = ropeRoot.points;
            if (pts.length === 0)
                return;

            let path = [];
            for (let i = 0; i <= ropeRoot.segmentCount; i++) {
                path.push(Qt.point(pts[i].x, pts[i].y));
            }
            polyline.path = path;
        }

        FrameAnimation {
            running: ropeRoot.initialized
            onTriggered: {
                const dt = Math.min(frameTime, 0.02);
                let pts = ropeRoot.points;
                if (pts.length === 0)
                    return;

                const restLen = Qt.point(ropeRoot.endX - ropeRoot.anchorX, ropeRoot.endY - ropeRoot.anchorY);
                const straightDist = Math.sqrt(restLen.x * restLen.x + restLen.y * restLen.y);
                const ropeLen = Math.max(straightDist * ropeRoot.slack, 1);
                const targetLen = ropeLen / ropeRoot.segmentCount;

                const gy = ropeRoot.gravity * dt * dt;
                for (let i = 0; i <= ropeRoot.segmentCount; i++) {
                    let p = pts[i];
                    if (p.pinned)
                        continue;

                    let vx = p.x - p.px;
                    let vy = p.y - p.py;
                    p.px = p.x;
                    p.py = p.y;
                    p.x = p.x + vx;
                    p.y = p.y + vy + gy;
                }

                for (let run = 0; run < ropeRoot.constraintIterations; run++) {
                    pts[0].x = ropeRoot.anchorX;
                    pts[0].y = ropeRoot.anchorY;
                    pts[ropeRoot.segmentCount].x = ropeRoot.endX;
                    pts[ropeRoot.segmentCount].y = ropeRoot.endY;

                    for (let i = 0; i < ropeRoot.segmentCount; i++) {
                        let pA = pts[i];
                        let pB = pts[i + 1];

                        let dx2 = pB.x - pA.x;
                        let dy2 = pB.y - pA.y;
                        let dist = Math.sqrt(dx2 * dx2 + dy2 * dy2);
                        if (dist === 0)
                            continue;

                        let error = targetLen - dist;
                        let ax = (dx2 / dist) * (error * 0.5);
                        let ay = (dy2 / dist) * (error * 0.5);

                        if (!pA.pinned) {
                            pA.x -= ax;
                            pA.y -= ay;
                        }
                        if (!pB.pinned) {
                            pB.x += ax;
                            pB.y += ay;
                        }
                    }
                }

                ropeRoot.updateVisuals();
            }
        }
    }

    Item {
        anchors.fill: parent

        Overlay {
            x: 0
            y: 0
            width: root.width
            height: root.selY
        }
        Overlay {
            x: 0
            y: root.selY
            width: root.selX
            height: root.selH
        }
        Overlay {
            x: root.selX + root.selW
            y: root.selY
            width: root.width - (root.selX + root.selW)
            height: root.selH
        }
        Overlay {
            x: 0
            y: root.selY + root.selH
            width: root.width
            height: root.height - (root.selY + root.selH)
        }

        Rope {
            anchors.fill: parent
            anchorX: 0
            anchorY: 0
            endX: root.selX
            endY: root.selY
        }
        Rope {
            anchors.fill: parent
            anchorX: root.width
            anchorY: 0
            endX: root.selX + root.selW
            endY: root.selY
        }
        Rope {
            anchors.fill: parent
            anchorX: 0
            anchorY: root.height
            endX: root.selX
            endY: root.selY + root.selH
        }
        Rope {
            anchors.fill: parent
            anchorX: root.width
            anchorY: root.height
            endX: root.selX + root.selW
            endY: root.selY + root.selH
        }

        Rectangle {
            id: cropBoundary
            x: root.selX
            y: root.selY
            width: root.selW
            height: root.selH
            color: "transparent"
            border.color: Theme.primaryColor
            border.width: 2
            opacity: dragArea.isDragging ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutSine
                }
            }

            Corner {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top
            }
            Corner {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
            }
            Corner {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom
            }
            Corner {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        cursorShape: Qt.CrossCursor

        property real startX: 0
        property real startY: 0
        property real curX: 0
        property real curY: 0
        property bool isDragging: false

        onPressed: e => {
            dragArea.startX = e.x;
            dragArea.startY = e.y;
            dragArea.curX = e.x;
            dragArea.curY = e.y;
            dragArea.isDragging = true;
            root.hasDragged = true;
        }
        onPositionChanged: e => {
            if (dragArea.isDragging) {
                dragArea.curX = e.x;
                dragArea.curY = e.y;
            }
        }
        onReleased: e => {
            const x = Math.round(Math.min(dragArea.startX, e.x));
            const y = Math.round(Math.min(dragArea.startY, e.y));
            const w = Math.round(Math.abs(e.x - dragArea.startX));
            const h = Math.round(Math.abs(e.y - dragArea.startY));

            if (w < 8 || h < 8) {
                dragArea.isDragging = false;
                root.hasDragged = false;
                ScreenshotConfig.dismiss();
                return;
            }
            if (ScreenshotConfig.isRecordingSelect) {
                ScreenshotConfig.regionPicked(x, y, w, h);
                ScreenshotConfig.dismiss();
                return;
            }

            cropSource.sourceRect = Qt.rect(x, y, w, h);
            cropSource.width = w;
            cropSource.height = h;

            cropSource.grabToImage(result => {
                if (!result) {
                    ScreenshotConfig.dismiss();
                    return;
                }

                const bmpPath = "/tmp/qs_screenshot_region_" + Date.now() + ".bmp";
                result.saveToFile(bmpPath);

                ScreenshotConfig.previewPath = bmpPath;
                ScreenshotConfig.isPreviewing = true;
                ScreenshotConfig.captureReady(bmpPath);
                ScreenshotConfig.dismiss();
            });
        }
    }
}
