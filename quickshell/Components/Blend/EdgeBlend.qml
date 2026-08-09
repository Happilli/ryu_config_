pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.Services.Paths

ShaderEffect {
    id: root

    property var source: null
    property rect rectA: Qt.rect(0, 0, 0, 0)
    property rect rectB: Qt.rect(0, 0, 0, 0)
    property color fillColor: Theme.surfaceContainer
    property real cornerRadius: 16
    property real smoothness: 24
    property bool active: false

    readonly property real gap: {
        const dx = Math.max(rectA.x - (rectB.x + rectB.width), rectB.x - (rectA.x + rectA.width), 0);
        const dy = Math.max(rectA.y - (rectB.y + rectB.height), rectB.y - (rectA.y + rectA.height), 0);
        return Math.max(dx, dy);
    }

    readonly property real effectiveK: Math.max(0.1, smoothness)

    visible: active && gap <= 1.0

    property vector2d itemSize: Qt.vector2d(width, height)
    property vector4d shapeColor: Qt.vector4d(fillColor.r, fillColor.g, fillColor.b, fillColor.a)
    property vector4d rectAv: Qt.vector4d(rectA.x, rectA.y, rectA.width, rectA.height)
    property vector4d rectBv: Qt.vector4d(rectB.x, rectB.y, rectB.width, rectB.height)
    property real blendK: effectiveK

    readonly property string shaderPath: PathService.home + "/.cache/safalQuick/shaders/sdf_blend"

    vertexShader: root.visible ? (root.shaderPath + "/sdf_blend.vert.qsb") : ""
    fragmentShader: root.visible ? (root.shaderPath + "/sdf_blend.frag.qsb") : ""
}
