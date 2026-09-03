pragma Singleton
import QtQuick
import qs.Services.Kraken
import qs.Services.Paths
import Quickshell

Singleton {
    id: root

    property bool isActive: false
    property real clockX: 0
    property real clockY: 0
    property real screenWidth: 0
    property real screenHeight: 0
    property real clockWidth: 0
    property real clockHeight: 0

    signal showPaimonClock
    signal hidePaimonClock

    Kraken {
        id: store
        filePath: PathService.state + "/paimonclockstate.json"
        onDataLoaded: {
            root.isActive = get("isActive", false);
            root.clockX = get("clockX", 0);
            root.clockY = get("clockY", 0);
        }
    }

    function _save() {
        store.set("isActive", root.isActive);
        store.set("clockX", root.clockX);
        store.set("clockY", root.clockY);
        store.save();
    }

    function randomizePosition() {
        if (!root.isActive)
            return;
        root.clockX = Math.floor(Math.random() * Math.max(0, root.screenWidth - root.clockWidth));
        root.clockY = Math.floor(Math.random() * Math.max(0, root.screenHeight * 0.5 - root.clockHeight));
        _save();
    }

    function show() {
        root.isActive = true;
        _save();
        root.showPaimonClock();
    }

    function hide() {
        root.isActive = false;
        _save();
        root.hidePaimonClock();
    }

    function toggle() {
        isActive ? hide() : show();
    }

    Component.onCompleted: store.reload()
}
