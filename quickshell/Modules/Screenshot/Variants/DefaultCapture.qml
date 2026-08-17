pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import qs.Configuration.Screenshot

Item {
    id: root
    required property var screen

    ScreencopyView {
        id: screcopy

        captureSource: root.screen ? root.screen : null
        live: false

        width: root.screen ? root.screen.width : 0
        height: root.screen ? root.screen.height : 0

        onHasContentChanged: {
            if (hasContent) {
                screcopy.grabToImage(result => {
                    if (!result) {
                        ScreenshotConfig.dismiss();
                        return;
                    }
                    const bmpPath = "/tmp/qs_screenshot_" + Date.now() + ".bmp";
                    result.saveToFile(bmpPath);
                    if (!ScreenshotConfig.silent) {
                        ScreenshotConfig.previewPath = bmpPath;
                        ScreenshotConfig.isPreviewing = true;
                    }
                    ScreenshotConfig.captureReady(bmpPath);
                    ScreenshotConfig.dismiss();
                });
            }
        }
    }
}
