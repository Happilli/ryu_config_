pragma Singleton
import QtQuick
import Quickshell
import qs.Services.Paths
import qs.Services.Kraken

Singleton {
    id: root

    property bool hyprsunsetActive: false
    property int temperature: 4000
    property int gamma: 80

    readonly property int tempStep: 55
    readonly property int gammaStep: 1
    readonly property int tempMin: 1000
    readonly property int tempMax: 6500
    readonly property int gammaMin: 10
    readonly property int gammaMax: 100
    readonly property string configPath: PathService.state + "/communication-config.json"

    signal hyprsunsetToggled(bool active)

    function saveConfig() {
        configKraken.set("temperature", root.temperature);
        configKraken.set("gamma", root.gamma);
        configKraken.set("hyprsunsetActive", root.hyprsunsetActive);
        configKraken.save();
    }

    function toggle() {
        hyprsunsetActive = !hyprsunsetActive;
        saveConfig();
        hyprsunsetToggled(hyprsunsetActive);

        Quickshell.execDetached(["pkill", "hyprsunset"]);
        if (hyprsunsetActive) {
            startTimer.restart();
            Quickshell.execDetached(["notify-send", "Night Mode", "Night mode enabled"]);
        } else {
            Quickshell.execDetached(["notify-send", "Night Mode", "Night mode disabled"]);
        }
    }

    function setTemperature(value) {
        const next = Math.max(tempMin, Math.min(tempMax, Math.round(value)));
        if (next === temperature)
            return;
        temperature = next;
        saveConfig();
        if (hyprsunsetActive)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", temperature.toString()]);
    }

    function setGamma(value) {
        const next = Math.max(gammaMin, Math.min(gammaMax, Math.round(value)));
        if (next === gamma)
            return;
        gamma = next;
        saveConfig();
        if (hyprsunsetActive)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "gamma", gamma.toString()]);
    }

    function increaseTemperature() {
        setTemperature(temperature + tempStep);
    }

    function decreaseTemperature() {
        setTemperature(temperature - tempStep);
    }

    function increaseGamma() {
        setGamma(gamma + gammaStep);
    }

    function decreaseGamma() {
        setGamma(gamma - gammaStep);
    }

    Timer {
        id: startTimer
        interval: 150
        repeat: false
        onTriggered: Quickshell.execDetached(["hyprsunset", "--temperature", root.temperature.toString(), "--gamma", root.gamma.toString()])
    }

    Component.onCompleted: {
        if (root.hyprsunsetActive)
            Quickshell.execDetached(["hyprsunset", "--temperature", root.temperature.toString(), "--gamma", root.gamma.toString()]);
    }

    Kraken {
        id: configKraken
        filePath: root.configPath
        onDataLoaded: {
            if (has("temperature"))
                root.temperature = get("temperature", 4000);
            if (has("gamma"))
                root.gamma = get("gamma", 80);
            if (has("hyprsunsetActive"))
                root.hyprsunsetActive = get("hyprsunsetActive", false);
        }
        onLoadFailed: error => {
            console.warn("communication config failed:", error);
            root.saveConfig();
        }
    }
}
