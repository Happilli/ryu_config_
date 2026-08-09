pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.Kraken
import qs.Services.Paths
import qs.utils

Singleton {
    id: root

    readonly property string themePath: PathService.state + "/theme.json"
    readonly property string colorsPath: PathService.state + "/colors.json"
    readonly property string defaultWallpaper: PathService.home + "/.config/quickshell/ryu-shell/Assets/defaults/default_wallpaper.jpeg"

    property bool isDarkMode: true
    property string currentSchemeType: "scheme-content"
    property string thumbPath: ""

    readonly property var schemeTypes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]

    readonly property string currentSchemeName: root.getSchemeDisplayName(root.currentSchemeType)

    function getSchemeDisplayName(schemeType) {
        const names = {
            "scheme-content": "Content",
            "scheme-expressive": "Expressive",
            "scheme-fidelity": "Fidelity",
            "scheme-fruit-salad": "Fruit Salad",
            "scheme-monochrome": "Monochrome",
            "scheme-neutral": "Neutral",
            "scheme-rainbow": "Rainbow",
            "scheme-tonal-spot": "Tonal Spot",
            "scheme-vibrant": "Vibrant"
        };
        return names[schemeType] || schemeType;
    }

    function setSchemeType(schemeType) {
        root.currentSchemeType = schemeType;
        root.saveTheme();
        root.generateColors();
    }

    property var _c: ({})

    function _get(key) {
        return root._c[key] ?? "";
    }

    property color backgroundColor: root._get("background")
    property color surfaceColor: root._get("surface")
    property color surfaceBright: root._get("surface_bright")
    property color surfaceContainer: root._get("surface_container")
    property color surfaceContainerLow: root._get("surface_container_low")
    property color surfaceContainerHigh: root._get("surface_container_high")
    property color surfaceContainerHighest: root._get("surface_container_highest")
    property color surfaceDim: root._get("surface_dim")
    property color primaryColor: root._get("primary")
    property color primaryContainer: root._get("primary_container")
    property color primaryFixed: root._get("primary_fixed")
    property color primaryFixedDim: root._get("primary_fixed_dim")
    property color secondaryColor: root._get("secondary")
    property color secondaryContainer: root._get("secondary_container")
    property color secondaryFixed: root._get("secondary_fixed")
    property color secondaryFixedDim: root._get("secondary_fixed_dim")
    property color tertiaryColor: root._get("tertiary")
    property color tertiaryContainer: root._get("tertiary_container")
    property color tertiaryFixed: root._get("tertiary_fixed")
    property color tertiaryFixedDim: root._get("tertiary_fixed_dim")
    property color errorColor: root._get("error")
    property color errorContainer: root._get("error_container")
    property color onBackground: root._get("on_background")
    property color onSurface: root._get("on_surface")
    property color onSurfaceVariant: root._get("on_surface_variant")
    property color onPrimary: root._get("on_primary")
    property color onPrimaryContainer: root._get("on_primary_container")
    property color onPrimaryFixed: root._get("on_primary_fixed")
    property color onPrimaryFixedVariant: root._get("on_primary_fixed_variant")
    property color onSecondary: root._get("on_secondary")
    property color onSecondaryContainer: root._get("on_secondary_container")
    property color onSecondaryFixed: root._get("on_secondary_fixed")
    property color onSecondaryFixedVariant: root._get("on_secondary_fixed_variant")
    property color onTertiary: root._get("on_tertiary")
    property color onTertiaryContainer: root._get("on_tertiary_container")
    property color onTertiaryFixed: root._get("on_tertiary_fixed")
    property color onTertiaryFixedVariant: root._get("on_tertiary_fixed_variant")
    property color onError: root._get("on_error")
    property color onErrorContainer: root._get("on_error_container")
    property color outlineColor: root._get("outline")
    property color outlineVariant: root._get("outline_variant")
    property color inverseSurface: root._get("inverse_surface")
    property color inverseOnSurface: root._get("inverse_on_surface")
    property color inversePrimary: root._get("inverse_primary")
    property color scrimColor: root._get("scrim")
    property color shadowColor: root._get("shadow")
    property color accentColor: root.primaryColor
    property color textColor: root.onBackground
    property color dimColor: root.outlineColor

    FileView {
        id: jsonFile
        path: root.colorsPath
        onLoaded: {
            try {
                const data = JSON.parse(jsonFile.text());
                root._c = data?.colors ?? {};
            } catch (e) {
                root._c = {};
            }
        }
        onLoadFailed: {
            root.generateColors();
        }
    }

    Process {
        id: matugenProcess
        onRunningChanged: {
            if (!running) {
                jsonFile.reload();
            }
        }
    }

    Kraken {
        id: themeKraken
        filePath: root.themePath

        onDataLoaded: {
            root.currentSchemeType = themeKraken.get("schemeType", "scheme-content");
            const saved = themeKraken.get("thumbPath", "");
            root.thumbPath = saved ? PathService.home + '/thumbs/' + saved : "";
            root.isDarkMode = themeKraken.get("isDarkMode", true);
        }

        onLoadFailed: error => {
            console.warn("theme config failed:", error);
            root.saveTheme();
        }
    }

    onIsDarkModeChanged: {
        root.saveTheme();
        root.generateColors();
    }

    function generateColors() {
        if (!WallpaperConfig.loaded) {
            WallpaperConfig.loadedChanged.connect(function onLoaded() {
                WallpaperConfig.loadedChanged.disconnect(onLoaded);
                root.generateColors();
            });
            return;
        }
        const src = WallpaperConfig.currentWallpaper || root.defaultWallpaper;
        const mode = root.isDarkMode ? "dark" : "light";
        const cmd = `mkdir -p ~/.cache/safalQuick && matugen --source-color-index 0 -m "${mode}" -t "${root.currentSchemeType}" image "${src}" && echo "matugen done" || echo "matugen failed"`;
        matugenProcess.command = ["/bin/sh", "-c", cmd];
        matugenProcess.running = true;
    }

    function saveTheme() {
        themeKraken.set("isDarkMode", root.isDarkMode);
        themeKraken.set("schemeType", root.currentSchemeType);
        if (root.thumbPath) {
            const filename = root.thumbPath.split("/").pop();
            themeKraken.set("thumbPath", filename);
        }
        themeKraken.save();
    }

    function toggleMode() {
        root.isDarkMode = !root.isDarkMode;
    }
}
