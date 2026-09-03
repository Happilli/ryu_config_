pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root

    property bool active: false
    readonly property bool isHovered: mouse.containsMouse
    property bool isEnabled: true
    property bool iconMirrored: false

    property string icon: ""
    property string label: ""
    property real contentPixelSize: root.icon ? 20 : 12
    property int contentWeight: root.active ? Font.Medium : Font.Normal
    default property alias extraContent: contentSlot.data
    property color activeColor: Theme.primaryContainer
    property color hoverColor: Theme.secondaryContainer
    property color inactiveColor: "transparent"
    property color activeBorderColor: Theme.primaryColor
    property color inactiveBorderColor: Theme.outlineVariant
    property color activeTextColor: Theme.onPrimaryContainer
    property color inactiveTextColor: Theme.onSurface
    property color hoverTextColor: activeTextColor
    property real activeBorderWidth: 2
    property real inactiveBorderWidth: 1
    property real hoverBorderWidth: 0
    property real colorAnimDuration: 150
    signal clicked
    enabled: root.isEnabled
    opacity: root.isEnabled ? 1 : 0.35
    color: root.active ? root.activeColor : (root.isHovered ? root.hoverColor : root.inactiveColor)
    border.color: root.active ? root.activeBorderColor : (root.isHovered && root.hoverBorderWidth > 0 ? Theme.outlineVariant : root.inactiveBorderColor)
    border.width: root.active ? root.activeBorderWidth : (root.isHovered ? root.hoverBorderWidth : root.inactiveBorderWidth)
    scale: mouse.pressed ? 0.9 : (root.isHovered || root.active ? 1.05 : 1.0)
    Behavior on color {
        ColorAnimation {
            duration: root.colorAnimDuration
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: root.colorAnimDuration
        }
    }
    Behavior on border.width {
        NumberAnimation {
            duration: root.colorAnimDuration
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: root.colorAnimDuration
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
            font.weight: root.contentWeight
            color: root.active ? root.activeTextColor : (root.isHovered ? root.hoverTextColor : root.inactiveTextColor)
            transform: Scale {
                xScale: root.iconMirrored ? -1 : 1
                origin.x: contentText.width / 2
                origin.y: contentText.height / 2
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.colorAnimDuration
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
