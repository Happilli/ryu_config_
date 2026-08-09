pragma ComponentBehavior: Bound
import QtQuick
import qs.Components.common
import qs.Services.Theme

Card {
    id: sizeSection

    property real currentSize: 2.0
    signal sizeSelected(real size)
    signal dropdownToggled(bool open, real globalX, real globalY)

    width: 100
    height: 64

    MorphButton {
        id: sizeButton
        anchors.centerIn: parent
        width: 84
        height: 52
        baseRadius: 8
        contentPixelSize: 24
        label: sizeSection.currentSize
        inactiveText: Theme.onSurface
        hoverColor: Theme.surfaceContainerHigh
        hoverBorderWidth: 1
        onClicked: {
            var pt = sizeSection.mapToItem(null, sizeSection.width / 2, 0);
            sizeSection.dropdownToggled(true, pt.x, pt.y);
        }
    }
}
