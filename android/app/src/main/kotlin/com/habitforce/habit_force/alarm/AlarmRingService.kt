package com.habitforce.habit_force.alarm

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.VibratorManager
import com.habitforce.habit_force.R
import com.habitforce.habit_force.history.EventLog
import com.habitforce.habit_force.notify.Notifier
import com.habitforce.habit_force.plan.PlanAlarm
import com.habitforce.habit_force.plan.PlanInvalid
import com.habitforce.habit_force.plan.Time

data class Ringing(val entry: PlanAlarm, val snoozeNo: Int)

/** Rings: sound at alarm volume, vibration, the alarm screen over the lock
 *  screen, and a ten-minute limit. docs/02-domain/alarms/lld.md §4 */
class AlarmRingService : Service() {
    companion object {
        const val ACTION_RING = "com.habitforce.habit_force.RING"
        const val ACTION_SNOOZE = "com.habitforce.habit_force.SNOOZE"
        const val ACTION_DISMISS = "com.habitforce.habit_force.DISMISS"
        const val EXTRA_DETAIL = "detail"
        private const val NOTIFICATION_ID = 2001
        private const val TIMEOUT_MS = 10 * 60_000L

        @Volatile var current: Ringing? = null
            private set

        val isRinging: Boolean get() = current != null

        /** Set by AlarmActivity while it is on screen, so a timeout closes it. */
        @Volatile var onStopped: (() -> Unit)? = null
    }

    private val handler = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_RING -> ring(intent)
            ACTION_SNOOZE -> snooze()
            ACTION_DISMISS -> dismiss(intent.getStringExtra(EXTRA_DETAIL))
            else -> if (current == null) stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun ring(intent: Intent) {
        Notifier.ensureChannels(this)
        val entry = try {
            PlanAlarm.parse(intent.getStringExtra(AlarmScheduler.EXTRA_ENTRY) ?: "")
        } catch (e: PlanInvalid) {
            null
        }
        // Started with startForegroundService: Android requires startForeground
        // within seconds whatever happens next, even for an entry that will
        // not parse.
        startForeground(NOTIFICATION_ID, notification(entry), ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        if (entry == null) {
            stop()
            return
        }
        // A second alarm replaces the first on screen.
        stopSound()
        handler.removeCallbacksAndMessages(null)
        current = Ringing(entry, intent.getIntExtra(AlarmScheduler.EXTRA_SNOOZE_NO, 0))
        play(entry)
        for (id in entry.alarmIds) EventLog.append(this, "alarm_fired", alarmId = id, detail = entry.label.ifEmpty { null })
        handler.postDelayed({ timeout() }, TIMEOUT_MS)
    }

    private fun notification(entry: PlanAlarm?): Notification {
        val screen = PendingIntent.getActivity(
            this, 1, Intent(this, AlarmActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return Notification.Builder(this, Notifier.CH_ALARMS)
            .setSmallIcon(R.drawable.ic_stat_habit)
            .setContentTitle(entry?.label?.ifEmpty { null } ?: "Alarm")
            .setContentText(entry?.let { Time.hhmm(it.minute) } ?: "")
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setFullScreenIntent(screen, true)
            .setContentIntent(screen)
            .build()
    }

    private fun play(entry: PlanAlarm) {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        if (uri != null) {
            player = try {
                MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build(),
                    )
                    setDataSource(this@AlarmRingService, uri)
                    isLooping = true
                    setWakeMode(this@AlarmRingService, PowerManager.PARTIAL_WAKE_LOCK)
                    prepare()
                    start()
                }
            } catch (e: Exception) {
                // No playable sound: vibration and the screen still carry it.
                null
            }
        }
        if (entry.vibrate) {
            getSystemService(VibratorManager::class.java).defaultVibrator.vibrate(
                VibrationEffect.createWaveform(longArrayOf(0, 800, 600), 0),
                VibrationAttributes.createForUsage(VibrationAttributes.USAGE_ALARM),
            )
        }
    }

    private fun snooze() {
        val r = current ?: return stop()
        // The button is not shown past the limit; refusing here too keeps the
        // limit true whatever sent the intent.
        if (r.snoozeNo + 1 > r.entry.snoozeLimit) return
        AlarmScheduler.armSnooze(this, r.entry, r.snoozeNo + 1)
        for (id in r.entry.alarmIds) EventLog.append(this, "alarm_snoozed", alarmId = id, detail = (r.snoozeNo + 1).toString())
        stop()
    }

    private fun dismiss(detail: String?) {
        val r = current ?: return stop()
        for (id in r.entry.alarmIds) EventLog.append(this, "alarm_dismissed", alarmId = id, detail = detail)
        stop()
    }

    private fun timeout() {
        val r = current ?: return stop()
        for (id in r.entry.alarmIds) EventLog.append(this, "alarm_missed", alarmId = id)
        stop()
    }

    private fun stopSound() {
        player?.run {
            try {
                stop()
            } catch (e: IllegalStateException) {
                // Never started; nothing to stop.
            }
            release()
        }
        player = null
        getSystemService(VibratorManager::class.java).defaultVibrator.cancel()
    }

    private fun stop() {
        handler.removeCallbacksAndMessages(null)
        stopSound()
        current = null
        onStopped?.invoke()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopSound()
        current = null
        super.onDestroy()
    }
}
