import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs.config
import qs.widgets.buttons

Scope {
    id: bar

    Variants {
        model: Quickshell.screens
        LazyLoader {
            id: bar_loader
            active: true
            readonly property int bar_height: Config.bar.height ?? 400
            required property var modelData
            component: PanelWindow {
                id: bar_root
                implicitHeight: bar_loader.bar_height
                exclusiveZone: bar_loader.bar_height

                screen: bar_loader.modelData

                //mask: Region {}

                color: "transparent"
                WlrLayershell.layer: WlrLayer.Top

                anchors {
                    top: (Config.options.bar?.bottom ?? false) ? false : true
                    bottom: (Config.options.bar?.bottom ?? false) ? true : false
                    left: true
                    right: true
                }

                Rectangle {
                    id: bar_content
                    height: bar_loader.bar_height

                    anchors.fill: parent
                    anchors.margins: 0

                    layer.enabled: true
                    layer.smooth: true

                    color: Design.colors.surface

                    //Bottom border
                    Rectangle {
                        id: border_bottom
                        height: Config.options.bar.border_size ?? 3

                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        visible: Config.options.bar.border ?? true

                        color: Design.colors.outline
                    }
                    RowLayout {
                        id: left_row_section
                        anchors {
                            leftMargin: 20
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                        }
                        LeftSideBar {}
                        ActiveWindow {}
                    }
                    //Date&Time
                    RowLayout {
                        id: middle_row_section
                        anchors.centerIn: parent

                        Workspace {
                            bar: bar_root
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Media {
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Date {
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                    RowLayout {
                        id: right_row_section
                        anchors {
                            rightMargin: 20
                        }
                    }
                }
            }
        }
    }
}
