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

Scope {
    id: runner

    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root

            required property var modelData
            property alias searchQuery: searchBar.searchQuery
            property alias searchBar: searchBar

            visible: States.is_runner_open

            WlrLayershell.namespace: "emphshell:runner"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "Transparent"

            implicitWidth: row_layout.implicitWidth
            implicitHeight: row_layout.implicitHeight

            Rectangle {
                id: background
                anchors.fill: parent
                color: Design.colors.surface
                radius: Design.corner.medium
                border {
                    color: Design.colors.on_surface
                    width: 1
                }
            }
            Connections {
                target: root

                function onVisibleChanged(): void {
                    root.searchQuery = "";
                }
            }

            ColumnLayout {
                id: row_layout
                implicitWidth: Config.runner.width
                spacing: 5
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                SearchBar {
                    id: searchBar
                }

                ListView {
                    id: itemList
                    visible: root.searchQuery !== ""
                    Layout.fillWidth: true
                    //implicitHeight: 600 < (appResults.contentHeight + topMargin + bottomMargin) ? (appResults.contentHeight + topMargin + bottomMargin) : 400
                    implicitHeight: Config.runner.extendedHeight ?? 400
                    clip: true
                    topMargin: 10
                    bottomMargin: 10
                    spacing: 2
                    orientation: Qt.Vertical

                    Connections {
                        target: root
                        function onSearchingTextChanged() {
                            if (itemList.count > 0)
                                itemList.currentIndex = 0;
                        }
                    }
                    onFocusChanged: {
                        if (focus)
                            itemList.currentIndex = 1;
                    }
                    model: ScriptModel {
                        id: model
                        objectProp: "key"
                        values: {
                            if (root.searchQuery == "")
                                return [];

                            const appResultObjects = AppUtils.appdb.getFilteredApps(root.searchQuery, 10).map(entry => {
                                entry.clickActionName = "Launch";
                                entry.type = "App";
                                entry.execute = () => AppUtils.launch(entry);
                                entry.icon = entry.entry.icon;
                                return entry;
                            });
                            let mathResult = Qalculator.eval(root.searchQuery);
                            const mathResultObject = {
                                clickActionName: "Calculate",
                                type: "Math",
                                result: mathResult.result,
                                expr: mathResult.expr,
                                error: mathResult.error
                            };

                            let result = [];
                            if (mathResultObject.error == "" && mathResultObject.result !== "") {
                                result = result.concat(mathResultObject);
                            }
                            result = result.concat(appResultObjects);

                            return result;
                        }
                    }
                    delegate: AppItem {
                        required property var modelData
                        required property var index
                        isSelected: index === itemList.currentIndex
                        anchors.left: parent?.left
                        anchors.right: parent?.right
                        anchors.leftMargin: Design.search_bar.padding / 2
                        anchors.rightMargin: Design.search_bar.padding / 2
                        button_spec: Design.button.small
                        entry: modelData
                    }
                }
            }
        }
    }
    IpcHandler {
        target: "runner"
        function toggle() {
            States.is_runner_open = !States.is_runner_open;
        }
    }
}
