pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Components.common
import qs.Services.Theme

Card {
    id: actionsSection
    property bool canUndo: false
    property bool canRedo: false
    signal undoClicked
    signal redoClicked
    signal clearClicked
    width: 160
    height: 64
    cardRadius: 12
    surface: Theme.surfaceContainerLow

    Row {
        anchors.centerIn: parent
        spacing: 8

        MaterialIconButton {
            width: 42
            height: 42
            type: MaterialIconButton.Outlined
            shape: MaterialIconButton.Square
            iconSize: 20
            iconText: "\uf0e2"
            iconColor: Theme.onSurface
            borderColor: Theme.outlineVariant
            borderWidth: 1
            enabled: actionsSection.canUndo
            onClicked: actionsSection.undoClicked()
        }

        MaterialIconButton {
            width: 42
            height: 42
            type: MaterialIconButton.Outlined
            shape: MaterialIconButton.Square
            iconSize: 20
            iconText: "\uf01e"
            iconColor: Theme.onSurface
            borderColor: Theme.outlineVariant
            borderWidth: 1
            enabled: actionsSection.canRedo
            onClicked: actionsSection.redoClicked()
        }

        MaterialIconButton {
            width: 42
            height: 42
            type: MaterialIconButton.Outlined
            shape: MaterialIconButton.Square
            iconSize: 20
            iconText: "\udb81\udfff"
            iconColor: Theme.onSurface
            borderColor: Theme.outlineVariant
            borderWidth: 1
            onClicked: actionsSection.clearClicked()
        }
    }
}
