pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Column {
    id: a
    property string title: ""
    property string subtitle: ""
    spacing: 12

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: a.title
        color: Theme.onSurface
        font.pixelSize: 15
        font.weight: Font.Medium
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: a.subtitle !== ""
        text: a.subtitle
        color: Theme.textSecondary
        font.pixelSize: 13
    }
}
