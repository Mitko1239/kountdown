import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_notificationsEnabled: notificationsEnabled.checked
    property alias cfg_soundEnabled: soundEnabled.checked
    property alias cfg_notificationSound: notificationSound.text

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: showSeconds
            Kirigami.FormData.label: i18n("Panel:")
            text: i18n("Show Seconds")
        }
        QQC2.CheckBox {
            id: notificationsEnabled
            Kirigami.FormData.label: i18n("Notifications:")
            text: i18n("Notify when the timer finishes")
        }
        QQC2.CheckBox {
            id: soundEnabled
            text: i18n("Play a sound")
            enabled: notificationsEnabled.checked
        }
        QQC2.TextField {
            id: notificationSound
            Kirigami.FormData.label: i18n("Sound file:")
            placeholderText: i18n("Path to a .wav or .oga file")
            enabled: soundEnabled.checked && notificationsEnabled.checked
        }
    }
}
