import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell

import qs.config
import qs.utils
import qs.widgets
import qs.widgets.cards
import qs.widgets.buttons

M3Button {
    id: root
    required property var entry
    property string name: entry.name ?? ""
    property string itemIcon: entry.icon ?? entry.startupClass ?? ""
    property QtObject typescale: Design.typescale.body.medium
    isSelected: false
    button_spec: Design.button.medium
    //property alias button: button
    implicitHeight: entry.type == "Math" ? Config.runner.listItem.mathHeight : Config.runner.listItem.height
    color: "transparent"//Design.colors.surface_container
    radius: button_spec.corner.square
    Loader {
        id: appLoader
        active: entry.type === "App"
        anchors {
            verticalCenter: parent.verticalCenter
            fill: parent
        }
        sourceComponent: RowLayout {
            id: rowLayout

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Design.search_bar.padding / 2
                M3Icon {
                    id: button
                    icon_size: root.button_spec.icon_size
                    source: Quickshell.iconPath(root.itemIcon, "image-missing")
                    iconFolder: ""
                }
                RichText {
                    text: root.name
                    color: Design.colors.on_surface
                    font {
                        family: root.typescale.font
                        pointSize: root.typescale.size
                    }
                }
            }
            RichText {
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: Design.search_bar.padding / 2
                text: root.entry.type
                font {
                    family: root.typescale.font
                    pointSize: root.typescale.size
                }
                color: Design.colors.on_surface
            }
        }
    }
    Loader {
        id: mathLoader
        active: entry.type === "Math"
        anchors {
            verticalCenter: parent.verticalCenter
            fill: parent
        }
        sourceComponent: M3Card {
            id: card
            RowLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                RichText {
                    text: entry.expr ?? "N/A"
                    font {
                        family: Design.typescale.headline.font
                        pointSize: Design.typescale.headline.medium.size
                    }
                }
                RichText {
                    text: "=" ?? ""
                    font {
                        family: Design.typescale.headline.font
                        pointSize: Design.typescale.headline.medium.size
                    }
                }
                RichText {
                    text: entry.result ?? "N/A"
                    font {
                        family: Design.typescale.headline.font
                        pointSize: Design.typescale.headline.medium.size
                    }
                }
            }
        }
    }
    onClicked: entry.execute()
}
