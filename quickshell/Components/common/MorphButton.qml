pragma ComponentBehavior: Bound
import QtQuick

ButtonBase {
    id: root

    property real baseRadius: 8
    property real hoverRadius: root.height / 2

    property alias activeText: root.activeTextColor
    property alias inactiveText: root.inactiveTextColor
    property alias hoverText: root.hoverTextColor
    property alias activeBorder: root.activeBorderColor
    property alias inactiveBorder: root.inactiveBorderColor

    radius: root.active ? root.hoverRadius : (root.isHovered ? root.hoverRadius : root.baseRadius)

    Behavior on radius {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
