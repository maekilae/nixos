pragma Singleton

import Quickshell
import QtQuick

import "root:/config/"

Singleton {
    id: root
    // an expression can be broken across multiple lines using {}
    readonly property string time: {
        // The passed format string matches the default output of
        // the `date` command.
        Qt.formatDateTime(clock.date, Config.options.time.time_format);
    }

    readonly property string date: {
        Qt.formatDateTime(clock.date, Config.options.time.date_format);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
