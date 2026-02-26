pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool is_bar_open: true
    property bool is_sidebar_left_open: false
    property bool is_sidebar_right_open: false
    property bool is_runner_open: false
    property bool is_osd_open: false
    property bool is_overview_open: false
}
