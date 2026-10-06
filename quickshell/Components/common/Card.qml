pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    default property alias content: contentItem.data
    property real cardRadius: 12
    property color surface: Theme.card
    property color borderColor: Theme.divider
    property real borderWidth: 1

    radius: cardRadius
    color: surface
    border.color: borderColor
    border.width: borderWidth

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
