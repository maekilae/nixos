import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import EmphShell

import qs
import qs.widgets
import qs.config
import qs.utils
import qs.modules.runner.Items

Item {
    id: root

    property alias searchQuery: searchBar.textInput.text
    Layout.fillWidth: true
    implicitWidth: parent.implicitWidth
    implicitHeight: Design.search_bar.size
    M3SearchBar {
        id: searchBar
        color: "transparent"
        isFocused: States.is_runner_open
        anchors.fill: parent
        Keys.onUpPressed: itemList.decrementCurrentIndex()
        Keys.onDownPressed: itemList.incrementCurrentIndex()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                States.is_runner_open = false;
            }
        }
        textInput.onAccepted: {
            if (itemList.count > 0) {
                // Get the first visible delegate and trigger its click
                let firstItem = itemList.itemAtIndex(itemList.currentIndex);
                if (firstItem && firstItem.clicked) {
                    firstItem.clicked();
                }
            }
        }
        Component.onCompleted: textInput.forceActiveFocus()
    }
}
