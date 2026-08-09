pragma ComponentBehavior: Bound
import QtQuick
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

        MorphButton {
            width: 42
            height: 42
            icon: "\uf0e2"
            isEnabled: actionsSection.canUndo
            onClicked: actionsSection.undoClicked()
        }

        MorphButton {
            width: 42
            height: 42
            icon: "\uf0e2"
            iconMirrored: true
            isEnabled: actionsSection.canRedo
            onClicked: actionsSection.redoClicked()
        }

        MorphButton {
            width: 42
            height: 42
            icon: "\udb81\udfff"
            onClicked: actionsSection.clearClicked()
        }
    }
}
