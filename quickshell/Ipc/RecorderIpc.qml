pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Configuration.Screenshot
import Quickshell

Item {
    id: root

    property bool isRecording: false
    readonly property string outputDir: Quickshell.env("HOME") + "/Videos"

    function timestampedFile() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");
        const ts = d.getFullYear() + pad(d.getMonth() + 1) + pad(d.getDate()) + "_" + pad(d.getHours()) + pad(d.getMinutes()) + pad(d.getSeconds());
        return root.outputDir + "/recording_" + ts + ".mp4";
    }

    function buildCmd(extraArgs, filePath, audioSource) {
        let cmd = ["wl-screenrec"];
        if (audioSource && audioSource !== "") {
            cmd = cmd.concat(["--audio", "--audio-device", audioSource]);
        }
        cmd = cmd.concat(extraArgs);
        cmd = cmd.concat(["-f", filePath]);
        return cmd;
    }

    Process {
        id: recProc
    }

    function stopRecording() {
        Quickshell.execDetached(["pkill", "-INT", "-x", "wl-screenrec"]);
        root.isRecording = false;
    }

    function startFull(audioSource) {
        const file = root.timestampedFile();
        recProc.command = root.buildCmd([], file, audioSource);
        recProc.running = true;
        root.isRecording = true;
    }

    property string pendingAudioSource: ""

    Connections {
        target: ScreenshotConfig
        function onRegionPicked(x, y, w, h) {
            const geo = `${x},${y} ${w}x${h}`;
            const file = root.timestampedFile();
            recProc.command = root.buildCmd(["-g", geo], file, root.pendingAudioSource);
            recProc.running = true;
            root.isRecording = true;
        }
    }

    IpcHandler {
        target: "recorder"

        function toggle(audioSource: string): string {
            if (root.isRecording) {
                root.stopRecording();
                return "recording stopped";
            } else {
                root.startFull(audioSource);
                return "recording started";
            }
        }

        function toggleRegion(audioSource: string): string {
            if (root.isRecording) {
                root.stopRecording();
                return "recording stopped";
            } else {
                root.pendingAudioSource = audioSource;
                ScreenshotConfig.isRecordingSelect = true;
                return "selecting region for recording";
            }
        }

        function startRegion(): string {
            ScreenshotConfig.isRecordingSelect = true;
            return "selecting region for recording";
        }

        function stop(): string {
            root.stopRecording();
            return "recording stopped";
        }
    }
}
