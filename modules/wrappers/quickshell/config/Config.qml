pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root
    property string file_path: Directories.shellConfigPath
    property alias options: config_opts_json_adapter
    property int read_write_delay: 50 // milliseconds
    property bool ready: false
    property bool block_writes: false

    property alias display: config_opts_json_adapter.display
    property alias bar: config_opts_json_adapter.bar
    property alias runner: config_opts_json_adapter.runner
    property alias sidebar: config_opts_json_adapter.sidebar
    property alias wm: config_opts_json_adapter.wm
    property alias time: config_opts_json_adapter.time
    property alias weather: config_opts_json_adapter.weather

    function setNestedValue(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.options;
        let parents = [obj];

        // Traverse and collect parent objects
        for (let i = 0; i < keys.length - 1; ++i) {
            if (!obj[keys[i]] || typeof obj[keys[i]] !== "object") {
                obj[keys[i]] = {};
            }
            obj = obj[keys[i]];
            parents.push(obj);
        }

        // Convert value to correct type using JSON.parse when safe
        let convertedValue = value;
        if (typeof value === "string") {
            let trimmed = value.trim();
            if (trimmed === "true" || trimmed === "false" || !isNaN(Number(trimmed))) {
                try {
                    convertedValue = JSON.parse(trimmed);
                } catch (e) {
                    convertedValue = value;
                }
            }
        }

        obj[keys[keys.length - 1]] = convertedValue;
    }

    Timer {
        id: fileReloadTimer
        interval: root.read_write_delay
        repeat: false
        onTriggered: {
            config_file_view.reload();
        }
    }

    Timer {
        id: fileWriteTimer
        interval: root.read_write_delay
        repeat: false
        onTriggered: {
            config_file_view.writeAdapter();
        }
    }
    FileView {
        id: config_file_view
        path: root.file_path
        watchChanges: true
        blockWrites: root.block_writes
        onFileChanged: fileReloadTimer.restart()
        onAdapterUpdated: fileWriteTimer.restart()
        onLoaded: root.ready = true
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }
        JsonAdapter {
            id: config_opts_json_adapter

            property JsonObject display: JsonObject {
                property int width: 2560
                property int height: 3840
                property string wallpaper_path: "/home/emph/Pictures/Wallpapers/eyes-on-black.png"
            }
            property JsonObject bar: JsonObject {
                property bool visible: true
                property bool blur: true

                property int height: 45

                property bool border: false
                property int border_size: 3

                property bool bottom: false

                property JsonObject date: JsonObject {
                    property int text_size: Design.typescale.body.medium.size
                }
                property JsonObject ws: JsonObject {
                    property int count: 5
                    property int button_size: 8
                    property int spacing: 10
                    property int active_width: 44
                    property int active_height: 16
                }
            }
            property JsonObject runner: JsonObject {
                property int width: display.width / 4
                property int height: 40
                property int extendedHeight: width / 2
                property int maxError: 3
                property JsonObject listItem: JsonObject {
                    property int height: 50
                    property int mathHeight: 100
                }
                property list<string> favorites: []
            }

            property JsonObject sidebar: JsonObject {
                property int width: 400
            }
            property JsonObject wm: JsonObject {
                property int gaps_out: 10
            }
            property JsonObject time: JsonObject {
                property string date_format: "ddd dd/MM"
                property string time_format: "MMM d hh:mm"
            }

            //Interval is "update_interval" * 10min
            property JsonObject weather: JsonObject {
                property int update_interval: 2
                property bool gps_enabled: true
                property string api_key: "your_api_key_here"
                property string country: "your_country_here"
                property string city: "your_city_here"
            }
        }
    }
}
