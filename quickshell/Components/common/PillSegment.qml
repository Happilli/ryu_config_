pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root

    property bool active: false
    property bool isHovered: mouseArea.containsMouse

    property color activeColor: Theme.primaryContainer
    property color inactiveColor: Theme.surfaceContainerHigh
    property color hoverColor: Theme.surfaceContainerHighest
    property color activeBorderColor: Theme.primaryColor
    property color inactiveBorderColor: Theme.outlineVariant
    property color activeTextColor: Theme.onPrimaryContainer
    property color inactiveTextColor: Theme.onSurface

    property real activeBorderWidth: 1
    property real inactiveBorderWidth: 0

    property string icon: ""
    property string label: ""
    property real contentPixelSize: 12
    property int contentWeight: root.active ? Font.Medium : Font.Normal

    default property alias extraContent: contentSlot.data

    signal clicked

    color: root.active ? root.activeColor : (root.isHovered ? root.hoverColor : root.inactiveColor)
    border.color: root.active ? root.activeBorderColor : root.inactiveBorderColor
    border.width: root.active ? root.activeBorderWidth : root.inactiveBorderWidth

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }
    Behavior on border.width {
        NumberAnimation {
            duration: 200
        }
    }
    Behavior on topLeftRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    Behavior on topRightRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    Behavior on bottomLeftRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    Behavior on bottomRightRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: contentSlot
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            visible: root.icon !== "" || root.label !== ""
            text: root.icon || root.label
            font.pixelSize: root.contentPixelSize
            font.weight: root.contentWeight
            color: root.active ? root.activeTextColor : root.inactiveTextColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
