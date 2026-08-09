pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland

Item {
    id: root

    property var canvasSource: null
    property var captureSource: null
    property bool ready: false

    property point jigglePos: Qt.point(0.5, 0.5)
    property real jiggleTime: 999.0

    readonly property bool jiggling: jiggleTimeAnim.running

    visible: false

    function activate(screen) {
        root.captureSource = screen;
        root.visible = true;
        root.ready = true;
        Qt.callLater(() => {
            bgCapture.captureFrame();
            strokesSource.scheduleUpdate();
        });
    }

    function deactivate() {
        root.visible = false;
        root.ready = false;
        root.captureSource = null;
        jiggleTimeAnim.stop();
    }

    function triggerJiggle(px, py) {
        if (!root.ready) {
            return;
        }
        root.jigglePos = Qt.point(px / root.width, py / root.height);
        root.jiggleTime = 0;
        jiggleTimeAnim.restart();
    }

    NumberAnimation {
        id: jiggleTimeAnim
        target: root
        property: "jiggleTime"
        from: 0
        to: 3
        duration: 1500
        running: false
        onFinished: root.jiggleTime = 999.0
    }

    Item {
        id: combined
        x: root.width * 2
        width: root.width
        height: root.height
        layer.enabled: true
        layer.smooth: true

        ScreencopyView {
            id: bgCapture
            anchors.fill: parent
            captureSource: root.captureSource
            live: false
        }

        ShaderEffectSource {
            id: strokesSource
            anchors.fill: parent
            sourceItem: root.canvasSource
            live: false
            hideSource: false
        }
    }

    ShaderEffect {
        anchors.fill: parent
        visible: root.jiggling

        property variant source: combined
        property point mousePos: root.jigglePos
        property real time: root.jiggleTime
        property real intensity: 1.0

        vertexShader: "qrc:/qt/qml/Drawness/jiggle/jiggle.vert.qsb"
        fragmentShader: "qrc:/qt/qml/Drawness/jiggle/jiggle.frag.qsb"
    }
}
