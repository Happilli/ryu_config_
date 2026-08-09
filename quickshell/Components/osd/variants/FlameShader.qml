pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Paths

ShaderEffect {
    id: root

    property variant source: null
    property bool running: true

    readonly property string shaderPath: PathService.home + "/.cache/safalQuick/shaders/flame"
    property real time: 0

    NumberAnimation on time {
        from: 0
        to: 100
        duration: 100000
        loops: Animation.Infinite
        running: root.running
    }

    vertexShader: root.shaderPath + "/flame.vert.qsb"
    fragmentShader: root.shaderPath + "/flame.frag.qsb"
}
