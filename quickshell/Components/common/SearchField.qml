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

    implicitHeight: inputHeight
    radius: 12
    color: Theme.cardInner
    border {
        width: 1
        color: Theme.outlineVariant
    }
    clip: true

    Text {
        id: searchIcon
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        text: "\uedfb"
        color: Theme.textSecondary
        font.pixelSize: 15
    }

    TextField {
        id: input
        anchors {
            left: searchIcon.right
            leftMargin: 6
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        height: root.inputHeight
        placeholderText: root.placeholderText
        placeholderTextColor: Theme.textSecondary
        color: Theme.onSurface
        font.pixelSize: 13
        background: null

        onTextChanged: root.textEdited()
        Keys.onReturnPressed: root.returnPressed()
    }
}
