pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Components.common
import qs.Services.Theme

Card {
    id: colorSection

    property color currentColor: Theme.primaryColor
    signal colorSelected(color color)

    width: 250
    height: 64

    readonly property list<color> colorPalette: [Theme.errorColor, Theme.secondaryColor, Theme.primaryColor, Theme.tertiaryColor, Theme.onSurface, Theme.surfaceContainerHighest]

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: colorSection.colorPalette

            delegate: MaterialIconButton {
                id: swatch

                required property color modelData

                width: 32
                height: 32
                type: MaterialIconButton.Filled
                shape: colorSection.currentColor === swatch.modelData ? MaterialIconButton.Round : MaterialIconButton.Square
                color: swatch.modelData
                onClicked: colorSection.colorSelected(swatch.modelData.toString())
            }
        }
    }
}
