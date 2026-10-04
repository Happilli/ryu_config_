pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.Services.Theme

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: "Search…"
    property alias inputFocused: input.activeFocus
    property real inputHeight: 38

    signal textEdited
    signal returnPressed

    function forceActiveFocus() {
        input.forceActiveFocus();
    }
    function clearFocus() {
        input.focus = false;
    }

    height: root.inputHeight
    radius: 12
    color: Theme.surfaceContainer
    border.color: Theme.outlineVariant
    border.width: 1
    clip: true

    Text {
        id: searchIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: "\uedfb"
        font.pixelSize: 15
        color: Theme.onSurface
    }

    TextField {
        id: input
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: searchIcon.right
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        height: root.inputHeight
        placeholderText: root.placeholderText
        placeholderTextColor: Theme.onSurface
        color: Theme.onSurface
        font.pixelSize: 13
        onTextChanged: root.textEdited()
        Keys.onReturnPressed: root.returnPressed()

        background: Item {}
    }
}
