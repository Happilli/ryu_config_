import QtQuick
import Ryu.Shapes

MaterialShape {
    id: root

    property real borderWidth: 0
    property color borderColor: color
    property string imageSource: ""
    property bool instantMorph: false

    implicitWidth: 100
    implicitHeight: 100

    color: "transparent"
    animated: !root.instantMorph
    source: root.imageSource
    border.width: root.borderWidth
    border.color: root.borderColor
}
