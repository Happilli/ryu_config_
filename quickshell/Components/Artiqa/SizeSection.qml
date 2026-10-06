pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Components.common
import qs.Services.Theme

Card {
    id: sizeSection

    property real currentSize: 2.0
    signal sizeSelected(real size)
    signal dropdownToggled(bool open, real globalX, real globalY)

    width: 100
    height: 64

    MaterialIconButton {
        anchors.centerIn: parent
        width: 84
        height: 52
        type: MaterialIconButton.Outlined
        shape: MaterialIconButton.Square
        iconSize: 24
        iconText: String(sizeSection.currentSize)
        iconColor: Theme.onSurface
        borderColor: Theme.outlineVariant
        borderWidth: 1
        onClicked: {
            var pt = sizeSection.mapToItem(null, sizeSection.width / 2, 0);
            sizeSection.dropdownToggled(true, pt.x, pt.y);
        }
    }
}
