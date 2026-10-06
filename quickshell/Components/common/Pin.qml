import QtQuick
import Ryu.Extraa
import qs.Services.Theme

MaterialIconButton {
    id: root

    property bool pinned: false

    width: 28
    height: 28
    type: MaterialIconButton.Standard
    shape: MaterialIconButton.Round
    iconText: "\uf08d"
    iconSize: 16
    iconColor: root.pinned ? Theme.primaryColor : Theme.textSecondary
    rotation: root.pinned ? 0 : 45

    Behavior on iconColor {
        ColorAnimation {
            duration: 200
        }
    }

    Behavior on rotation {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
