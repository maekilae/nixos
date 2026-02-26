//https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/services/MaterialThemeLoader.qml
pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Automatically reloads generated material colors.
 * It is necessary to run reapplyTheme() on startup because Singletons are lazily loaded.
 */
Singleton {
    id: root
    property string filePath: Directories.generatedMaterialThemePath

    function reapplyTheme() {
        themeFileView.reload();
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent);
        for (const key in json) {
            if (json.hasOwnProperty(key)) {
                Design.colors[key] = json[key];
            }
        }
    }

    function resetFilePathNextTime() {
        resetFilePathNextWallpaperChange.enabled = true;
    }

    Connections {
        id: resetFilePathNextWallpaperChange
        enabled: true
        target: Config.options.display
        function onWallpaperPathChanged() {
            print("Wallpaper path changed");
            root.filePath = "";
            root.filePath = Directories.generatedMaterialThemePath;
            resetFilePathNextWallpaperChange.enabled = false;
        }
    }

    Timer {
        id: delayedFileRead
        interval: Config.options.options?.hacks?.arbitraryRaceConditionDelay ?? 1000
        repeat: false
        running: false
        onTriggered: {
            root.applyColors(themeFileView.text());
        }
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload();
            delayedFileRead.start();
        }
        onLoadedChanged: {
            const fileContent = themeFileView.text();
            root.applyColors(fileContent);
        }
        onLoadFailed: root.resetFilePathNextTime()
    }
}
