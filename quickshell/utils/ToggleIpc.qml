pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

Item {
    id: root

    required property string ipcName
    required property var config

    IpcHandler {
        target: root.ipcName

        function toggle(): string {
            root.config.isActive ? root.config.hide() : root.config.show();
            return root.ipcName + " toggled";
        }

        function activate(): string {
            root.config.show();
            return root.ipcName + " shown";
        }

        function deactivate(): string {
            root.config.hide();
            return root.ipcName + " hidden";
        }
    }
}
