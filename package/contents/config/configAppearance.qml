import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_showSeconds: showSeconds.checked

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: showSeconds
            text: i18n("Show Seconds in Panel")
        }
    }
}
