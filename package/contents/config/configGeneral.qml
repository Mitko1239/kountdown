import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property string cfg_mode
    property alias cfg_targetDateTime: targetDateTime.text
    property alias cfg_durationHours: durationHours.value
    property alias cfg_durationMinutes: durationMinutes.value
    property alias cfg_durationSeconds: durationSeconds.value
    property alias cfg_timerName: timerName.text
    property bool syncingTargetControls: false
    property bool initializingMode: true

    function twoDigits(value) { return value < 10 ? "0" + value : String(value) }
    function daysInMonth(year, month) { return new Date(year, month, 0).getDate() }
    function formatDateTime(date) {
        return date.getFullYear() + "-" + twoDigits(date.getMonth() + 1) + "-" + twoDigits(date.getDate()) + " " + twoDigits(date.getHours()) + ":" + twoDigits(date.getMinutes()) + ":" + twoDigits(date.getSeconds())
    }
    function parseDateTime(value) {
        if (!value || value.trim() === "") return new Date()
        var parts = value.trim().split(" ")
        if (parts.length !== 2) return new Date()
        var d = parts[0].split("-")
        var t = parts[1].split(":")
        if (d.length !== 3 || t.length < 2) return new Date()
        var parsed = new Date(Number(d[0]), Number(d[1]) - 1, Number(d[2]), Number(t[0]), Number(t[1]), t.length >= 3 ? Number(t[2]) : 0)
        return isNaN(parsed.getTime()) ? new Date() : parsed
    }
    function syncControlsFromTarget() {
        var date = parseDateTime(targetDateTime.text)
        syncingTargetControls = true
        yearSpin.value = date.getFullYear()
        monthSpin.value = date.getMonth() + 1
        daySpin.to = daysInMonth(yearSpin.value, monthSpin.value)
        daySpin.value = Math.min(date.getDate(), daySpin.to)
        hourSpin.value = date.getHours()
        minuteSpin.value = date.getMinutes()
        secondSpin.value = date.getSeconds()
        syncingTargetControls = false
    }
    function syncTargetFromControls() {
        if (syncingTargetControls) return
        var maxDay = daysInMonth(yearSpin.value, monthSpin.value)
        if (daySpin.value > maxDay) daySpin.value = maxDay
        daySpin.to = maxDay
        var date = new Date(yearSpin.value, monthSpin.value - 1, daySpin.value, hourSpin.value, minuteSpin.value, secondSpin.value)
        targetDateTime.text = formatDateTime(date)
    }
    function setTargetNow() {
        targetDateTime.text = formatDateTime(new Date())
        syncControlsFromTarget()
    }
    function ensureTargetDateTimeValue() {
        var parsed = parseDateTime(targetDateTime.text)
        if (!targetDateTime.text || targetDateTime.text.trim() === "" || parsed.getTime() <= 0) {
            targetDateTime.text = formatDateTime(new Date())
            return
        }
        targetDateTime.text = formatDateTime(parsed)
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: mode
            Kirigami.FormData.label: i18n("Countdown type:")
            textRole: "label"
            model: [
                { label: i18n("Duration"), name: "duration" },
                { label: i18n("Date and time"), name: "datetime" }
            ]
            onCurrentIndexChanged: {
                if (root.initializingMode) return
                if (currentIndex >= 0 && currentIndex < model.length) root.cfg_mode = model[currentIndex].name
                if (root.cfg_mode === "datetime") {
                    root.ensureTargetDateTimeValue()
                    root.syncControlsFromTarget()
                }
            }
            Component.onCompleted: {
                if (root.cfg_mode !== "duration" && root.cfg_mode !== "datetime") root.cfg_mode = "duration"
                currentIndex = root.cfg_mode === "datetime" ? 1 : 0
                root.initializingMode = false
            }
        }

        QQC2.TextField {
            id: timerName
            Kirigami.FormData.label: i18n("Timer name:")
            placeholderText: i18n("My timer")
        }

        Item {
            visible: root.cfg_mode === "datetime"
            Kirigami.FormData.label: i18n("Target:")
            implicitWidth: targetControls.implicitWidth
            implicitHeight: targetControls.implicitHeight
            onVisibleChanged: {
                if (visible) {
                    root.ensureTargetDateTimeValue()
                    root.syncControlsFromTarget()
                }
            }

            ColumnLayout {
                id: targetControls
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing

                QQC2.TextField {
                    id: targetDateTime
                    Layout.fillWidth: true
                    readOnly: true
                    placeholderText: "2026-12-31 23:59:00"
                }

                RowLayout {
                    QQC2.Button {
                        text: i18n("Now")
                        onClicked: root.setTargetNow()
                    }
                    QQC2.Label { text: i18n("Date:") }
                    QQC2.SpinBox {
                        id: yearSpin
                        from: 1970
                        to: 9999
                        onValueChanged: root.syncTargetFromControls()
                    }
                    QQC2.SpinBox {
                        id: monthSpin
                        from: 1
                        to: 12
                        onValueChanged: root.syncTargetFromControls()
                    }
                    QQC2.SpinBox {
                        id: daySpin
                        from: 1
                        to: 31
                        onValueChanged: root.syncTargetFromControls()
                    }
                }

                RowLayout {
                    QQC2.Label { text: i18n("Time:") }
                    QQC2.SpinBox {
                        id: hourSpin
                        from: 0
                        to: 23
                        onValueChanged: root.syncTargetFromControls()
                    }
                    QQC2.SpinBox {
                        id: minuteSpin
                        from: 0
                        to: 59
                        onValueChanged: root.syncTargetFromControls()
                    }
                    QQC2.SpinBox {
                        id: secondSpin
                        from: 0
                        to: 59
                        onValueChanged: root.syncTargetFromControls()
                    }
                }
            }
        }

        QQC2.SpinBox {
            id: durationHours
            visible: root.cfg_mode === "duration"
            Kirigami.FormData.label: i18n("Hours:")
            from: 0
            to: 999999
        }
        QQC2.SpinBox {
            id: durationMinutes
            visible: root.cfg_mode === "duration"
            Kirigami.FormData.label: i18n("Minutes:")
            from: 0
            to: 59
        }
        QQC2.SpinBox {
            id: durationSeconds
            visible: root.cfg_mode === "duration"
            Kirigami.FormData.label: i18n("Seconds:")
            from: 0
            to: 59
        }
    }

    Component.onCompleted: {
        ensureTargetDateTimeValue()
        syncControlsFromTarget()
    }
}
