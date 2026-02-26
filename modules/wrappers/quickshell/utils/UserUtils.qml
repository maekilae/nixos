pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string distro_name: "Unknown"
    property string distro_version: "Unknown"
    property string distro_architecture: "Unknown"
    property string distro_build_id: "Unknown"
    property string distro_icon: "linux-symbolic"
    property string ansi_color: "38,2,23,147,209"
    property string home_url: "https://archlinux.org/"
    property string documentation_url: "https://wiki.archlinux.org/"
    property string support_url: "https://bbs.archlinux.org/"
    property string bug_report_url: "https://gitlab.archlinux.org/groups/archlinux/-/issues"
    property string privacy_policy_url: "https://terms.archlinux.org/docs/privacy-policy"
    property string username: "Unknown User"
    property string profile_picture: "Unknown"

    Timer {
        triggeredOnStart: true
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            get_user.running = true;
            root.profile_picture = "/var/lib/AccountsService/icons/" + root.username;
        }
    }

    Process {
        id: get_user
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                root.username = data.trim();
            }
        }
    }
}
