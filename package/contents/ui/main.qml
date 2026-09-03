import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    Plasmoid.title: i18n("Kountdown")
    Plasmoid.icon: "chronometer"
    Plasmoid.constraintHints: PlasmaCore.Types.CanFillArea
    toolTipMainText: displayTimerName()
    toolTipSubText: hasTimer ? formatRemaining(remainingSeconds) : i18n("No active countdown")

    property real targetTimestamp: 0
    property int remainingSeconds: 0
    property bool finished: false
    property bool hasTimer: false
    property bool pendingConfigRestart: false
    readonly property bool isPanel: plasmoid.formFactor === PlasmaCore.Types.Horizontal || plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool isVerticalPanel: plasmoid.formFactor === PlasmaCore.Types.Vertical

    preferredRepresentation: isPanel ? compactRepresentation : fullRepresentation

    function twoDigits(value) { return value < 10 ? "0" + value : String(value) }
    function displayTimerName() {
        var name = String(plasmoid.configuration.timerName || "").trim()
        return name !== "" ? name : i18n("Kountdown")
    }
    function durationInSeconds() { return Number(plasmoid.configuration.durationHours) * 3600 + Number(plasmoid.configuration.durationMinutes) * 60 + Number(plasmoid.configuration.durationSeconds) }
    function parseTargetDateTime(value) {
        if (!value || value.trim() === "") return 0
        var parts=value.trim().split(" "); if (parts.length !== 2) return 0
        var d=parts[0].split("-"), t=parts[1].split(":"); if (d.length!==3 || t.length<2) return 0
        var date=new Date(Number(d[0]),Number(d[1])-1,Number(d[2]),Number(t[0]),Number(t[1]),t.length>=3?Number(t[2]):0)
        return isNaN(date.getTime()) ? 0 : date.getTime()
    }
    function formatRemaining(seconds) {
        if (!hasTimer) return i18n("No timer")
        if (seconds <= 0) return i18n("Finished")
        var days=Math.floor(seconds/86400), h=Math.floor((seconds%86400)/3600), m=Math.floor((seconds%3600)/60), s=seconds%60
        var result=twoDigits(h)+":"+twoDigits(m)+":"+twoDigits(s); if (days>0) result=days+"d "+result; return result
    }
    function formatCompactRemaining(seconds) {
        if (!hasTimer) return i18n("No Timer"); if (seconds<=0) return i18n("Done")
        var days=Math.floor(seconds/86400)
        var h=Math.floor((seconds%86400)/3600), m=Math.floor((seconds%3600)/60), s=seconds%60
        if (days>0) return plasmoid.configuration.showSeconds ? days+"d "+twoDigits(h)+":"+twoDigits(m)+":"+twoDigits(s) : days+"d "+twoDigits(h)+":"+twoDigits(m)
        h=Math.floor(seconds/3600)
        m=Math.floor((seconds%3600)/60)
        s=seconds%60
        if (h>0) return plasmoid.configuration.showSeconds ? twoDigits(h)+":"+twoDigits(m)+":"+twoDigits(s) : twoDigits(h)+":"+twoDigits(m)
        return plasmoid.configuration.showSeconds ? twoDigits(m)+":"+twoDigits(s) : twoDigits(m)+"m"
    }
    function formatDuration() {
        var h=Number(plasmoid.configuration.durationHours), m=Number(plasmoid.configuration.durationMinutes), s=Number(plasmoid.configuration.durationSeconds), r=""
        if(h>0) r=i18n("%1 h",h); if(m>0) r+=(r?" ":"")+i18n("%1 min",m); if(s>0||r==="") r+=(r?" ":"")+i18n("%1 s",s); return r
    }
    function asBool(value) { return value === true || value === "true" || value === 1 || value === "1" }
    function openSettingsDialog() {
        const configureAction = plasmoid.internalAction("configure")
        if (configureAction) configureAction.trigger()
    }
    function clearStoredActiveTimer() {
        plasmoid.configuration.activeTimerRunning = false
        plasmoid.configuration.activeTimerTargetTimestamp = "0"
    }
    function restoreActiveTimer() {
        var storedTarget = Number(plasmoid.configuration.activeTimerTargetTimestamp)
        if (!asBool(plasmoid.configuration.activeTimerRunning) || !isFinite(storedTarget) || storedTarget <= Date.now()) { stopTimer(); return }
        targetTimestamp = storedTarget
        remainingSeconds = Math.max(0, Math.ceil((targetTimestamp - Date.now()) / 1000))
        finished = remainingSeconds <= 0
        hasTimer = !finished
        if (!hasTimer) clearStoredActiveTimer()
    }
    function startTimer() {
        var target=plasmoid.configuration.mode==="datetime" ? parseTargetDateTime(plasmoid.configuration.targetDateTime) : Date.now()+durationInSeconds()*1000
        if(target<=Date.now()){ stopTimer(); return false }
        targetTimestamp=target; remainingSeconds=Math.ceil((target-Date.now())/1000); finished=false; hasTimer=true
        plasmoid.configuration.activeTimerRunning = true
        plasmoid.configuration.activeTimerTargetTimestamp = String(Math.round(targetTimestamp))
        return true
    }
    function stopTimer() { targetTimestamp=0; remainingSeconds=0; finished=false; hasTimer=false; clearStoredActiveTimer() }
    function updateCountdown() {
        if(!hasTimer||targetTimestamp<=0)return
        remainingSeconds=Math.max(0,Math.ceil((targetTimestamp-Date.now())/1000))
        if(remainingSeconds<=0&&!finished){ finished=true; clearStoredActiveTimer() }
    }
    function resetAndRestartTimerForConfigChange() {
        if (!(hasTimer || asBool(plasmoid.configuration.activeTimerRunning) || pendingConfigRestart)) return
        pendingConfigRestart = true
        stopTimer()
        if (startTimer()) pendingConfigRestart = false
    }

    Component.onCompleted: {
        if (!asBool(plasmoid.configuration.hasInitializedStartupState)) {
            stopTimer()
            plasmoid.configuration.hasInitializedStartupState = true
            return
        }
        if (!asBool(plasmoid.configuration.activeTimerRunning)) {
            stopTimer()
            return
        }
        restoreActiveTimer()
    }

    Timer { interval: 250; repeat: true; running: true; onTriggered: root.updateCountdown() }
    Connections {
        target: plasmoid.configuration
        function onModeChanged() { root.resetAndRestartTimerForConfigChange() }
        function onTargetDateTimeChanged() { root.resetAndRestartTimerForConfigChange() }
        function onDurationHoursChanged() { root.resetAndRestartTimerForConfigChange() }
        function onDurationMinutesChanged() { root.resetAndRestartTimerForConfigChange() }
        function onDurationSecondsChanged() { root.resetAndRestartTimerForConfigChange() }
    }

    compactRepresentation: Component {
        Item {
            id: compactArea
            readonly property real compactContentWidth: Math.max(compactTitleLabel.implicitWidth, compactTimerLabel.implicitWidth)
            implicitWidth: Math.max(root.isVerticalPanel ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit * 12, compactContentWidth + Kirigami.Units.largeSpacing * 2)
            implicitHeight: Math.max(Kirigami.Units.gridUnit * 3, compactLayout.implicitHeight + Kirigami.Units.smallSpacing * 2)

            MouseArea {
                id: compactMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !plasmoid.userConfiguring
                onClicked: root.expanded = !root.expanded
            }

            ColumnLayout {
                id: compactLayout
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.smallSpacing
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                spacing: 0

                PlasmaComponents.Label {
                    id: compactTitleLabel
                    Layout.fillWidth: true
                    text: root.displayTimerName()
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    opacity: 0.8
                }
                PlasmaComponents.Label {
                    id: compactTimerLabel
                    Layout.fillWidth: true
                    text: root.formatCompactRemaining(root.remainingSeconds)
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.bold: true
                }
            }
        }
    }

    fullRepresentation: Component {
        Item {
            id: fullView
            implicitWidth: Kirigami.Units.gridUnit * 22
            implicitHeight: Kirigami.Units.gridUnit * 12
            Layout.minimumWidth: Kirigami.Units.gridUnit*18
            Layout.minimumHeight: Kirigami.Units.gridUnit*10
            Layout.preferredWidth: Kirigami.Units.gridUnit*22
            Layout.preferredHeight: Kirigami.Units.gridUnit*12
            ColumnLayout {
                anchors.fill: parent; anchors.margins: Kirigami.Units.largeSpacing
                PlasmaComponents.Label { Layout.fillWidth:true; text:root.displayTimerName(); horizontalAlignment:Text.AlignHCenter }
                PlasmaComponents.Label { Layout.fillWidth:true; Layout.fillHeight:true; text:root.formatRemaining(root.remainingSeconds); horizontalAlignment:Text.AlignHCenter; verticalAlignment:Text.AlignVCenter; font.bold:true; font.pixelSize:Math.max(Kirigami.Units.gridUnit*2,Math.min(fullView.width/5,fullView.height/2)) }
                PlasmaComponents.Label { Layout.fillWidth:true; text:root.hasTimer?(plasmoid.configuration.mode==="datetime"?i18n("Target: %1",plasmoid.configuration.targetDateTime):i18n("Duration: %1",root.formatDuration())):i18n("No active countdown"); horizontalAlignment:Text.AlignHCenter; opacity:.7; elide:Text.ElideRight }
                RowLayout {
                    Layout.alignment:Qt.AlignHCenter
                    PlasmaComponents.Button { text:i18n("Start"); icon.name:"media-playback-start"; enabled:!root.hasTimer||root.finished; onClicked:root.startTimer() }
                    PlasmaComponents.Button { text:i18n("Stop"); icon.name:"media-playback-stop"; enabled:root.hasTimer&&!root.finished; onClicked:root.stopTimer() }
                    PlasmaComponents.Button {
                        text: i18n("Settings")
                        icon.name: "configure"
                        onClicked: root.openSettingsDialog()
                    }
                }
            }
        }
    }
}
