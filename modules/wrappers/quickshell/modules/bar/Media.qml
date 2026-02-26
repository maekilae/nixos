//https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/modules/ii/bar/Media.qml
import qs.widgets.buttons
import qs.widgets
import qs.services
import qs.config

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Hyprland

Item {
    id: root
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: activePlayer?.trackTitle || "No media"

    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: Design.button.extra_small.size

    Timer {
        running: activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: 3000
        repeat: true
        onTriggered: activePlayer.positionChanged()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton | Qt.LeftButton
        onPressed: event => {
            if (event.button === Qt.MiddleButton) {
                activePlayer.togglePlaying();
            } else if (event.button === Qt.BackButton) {
                activePlayer.previous();
            } else if (event.button === Qt.ForwardButton || event.button === Qt.RightButton) {
                activePlayer.next();
            } else if (event.button === Qt.LeftButton)
            //GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
            {}
        }
    }
    M3Button {
        button_spec: Design.button.extra_small
        anchors.fill: parent
        onClicked: {}

        RowLayout { // Real content
            id: rowLayout
            spacing: 1
            anchors.fill: parent
            RichText {
                //visible: Config.options.options.bar.verbose
                width: rowLayout.width
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Design.button.extra_small.padding
                Layout.leftMargin: Design.button.extra_small.padding
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight // Truncates the text on the right
                color: Design.colors.on_surface
                text: `${cleanedTitle}${activePlayer?.trackArtist ? ' • ' + activePlayer.trackArtist : ''}`
                font {
                    family: Design.typescale.body.medium.font
                    pointSize: Design.typescale.body.small.size
                }
            }
        }
    }
}
