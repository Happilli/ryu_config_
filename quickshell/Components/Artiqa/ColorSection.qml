pragma ComponentBehavior: Bound
import QtQuick
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

            delegate: MorphButton {
                id: colorButton

                required property color modelData

                width: 32
                height: 32
                baseRadius: 6
                hoverRadius: 16
                active: colorSection.currentColor === colorButton.modelData
                activeColor: colorButton.modelData
                inactiveColor: colorButton.modelData
                activeBorder: Theme.primaryColor
                activeBorderWidth: 3
                hoverBorderWidth: 2
                onClicked: colorSection.colorSelected(colorButton.modelData.toString())
            }
        }
    }
}
