pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root
    property bool active: false
    property string icon: ""
    property string label: ""
    property bool iconMirrored: false
    property color activeColor: Theme.primaryContainer
    property color activeBorder: Theme.primaryColor
    property color activeText: Theme.onPrimaryContainer
    property real hoverRadius: height / 2
    property real baseRadius: 8
    signal clicked

    readonly property bool hovering: mouse.containsMouse

    radius: active ? hoverRadius : (hovering ? hoverRadius : baseRadius)
    color: active ? activeColor : (hovering ? Theme.surfaceContainerHigh : "transparent")
    border.color: active ? activeBorder : "transparent"
    border.width: active ? 2 : 0
    scale: mouse.pressed ? 0.9 : (hovering ? 1.05 : 1.0)

    Behavior on radius {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutBack
        }
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        text: root.icon || root.label
        font.pixelSize: root.icon ? 20 : 12
        color: root.active ? root.activeText : Theme.onSurface
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        transform: Scale {
            xScale: root.iconMirrored ? -1 : 1
            origin.x: iconText.width / 2
            origin.y: iconText.height / 2
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
