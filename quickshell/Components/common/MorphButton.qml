pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool iconMirrored: false

    property color hoverText: activeText
    property real contentPixelSize: root.icon ? 20 : 12
    default property alias extraContent: contentSlot.data
    property real inactiveBorderWidth: 0

    property bool active: false
    property bool isHovered: mouse.containsMouse
    property bool isEnabled: true

    property color activeColor: Theme.primaryContainer
    property color hoverColor: Theme.surfaceContainerHigh
    property color inactiveColor: "transparent"
    property color activeBorder: Theme.primaryColor
    property color inactiveBorder: "transparent"
    property color activeText: Theme.onPrimaryContainer
    property color inactiveText: Theme.onSurface

    property real baseRadius: 8
    property real hoverRadius: root.height / 2
    property real activeBorderWidth: 2
    property real hoverBorderWidth: 0

    signal clicked

    enabled: root.isEnabled
    opacity: root.isEnabled ? 1 : 0.35

    radius: root.active ? root.hoverRadius : (root.isHovered ? root.hoverRadius : root.baseRadius)
    color: root.active ? root.activeColor : (root.isHovered ? root.hoverColor : root.inactiveColor)
    border.color: root.active ? root.activeBorder : (root.isHovered && root.hoverBorderWidth > 0 ? Theme.outlineVariant : root.inactiveBorder)
    border.width: root.active ? root.activeBorderWidth : (root.isHovered ? root.hoverBorderWidth : root.inactiveBorderWidth)
    scale: mouse.pressed ? 0.9 : (root.isHovered || root.active ? 1.05 : 1.0)

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
    Behavior on border.width {
        NumberAnimation {
            duration: 150
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutBack
        }
    }

    Item {
        id: contentSlot
        anchors.centerIn: parent

        Text {
            id: contentText
            anchors.centerIn: parent
            visible: root.icon !== "" || root.label !== ""
            text: root.icon || root.label
            font.pixelSize: root.contentPixelSize
            font.weight: root.active ? Font.Medium : Font.Normal
            color: root.active ? root.activeText : (root.isHovered ? root.hoverText : root.inactiveText)

            transform: Scale {
                xScale: root.iconMirrored ? -1 : 1
                origin.x: contentText.width / 2
                origin.y: contentText.height / 2
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
