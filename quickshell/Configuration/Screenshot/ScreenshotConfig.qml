pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    //for region recording purposes testing
    property bool isRecordingSelect: false
    signal regionPicked(real x, real y, real w, real h)
    property bool isSelectingRegion: false
    property bool isLassoing: false
    property bool isCapturing: false
    property bool isPreviewing: false
    property string previewPath: ""

    property var lassoPoints: []

    readonly property bool isActive: isSelectingRegion || isRecordingSelect || isLassoing || isCapturing || isPreviewing

    signal captureReady(string path)

    function dismiss() {
        isCapturing = false;
        isSelectingRegion = false;
        isRecordingSelect = false;
        isLassoing = false;
        lassoPoints = [];
    }

    function dismissPreview() {
        isPreviewing = false;
        previewPath = "";
    }
}
