package com.example.lifemate

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmService : Service() {

    companion object {
        private const val TAG = "AlarmService"
        private const val CHANNEL_ID = "lifemate_clock_alarm_channel_v1"
        private const val NOTIFICATION_ID = 99991
        var isServiceRunning = false
            private set
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var autoStopHandler: android.os.Handler? = null
    private var autoStopRunnable: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: "START_ALARM"

        if (action == "STOP_ALARM") {
            stopAlarm()
            stopSelf()
            return START_NOT_STICKY
        }

        val taskId = intent?.getStringExtra("taskId") ?: ""
        val title = intent?.getStringExtra("title") ?: "Lifemate Alarm"
        val notes = intent?.getStringExtra("notes") ?: ""
        val notificationId = intent?.getIntExtra("notificationId", NOTIFICATION_ID) ?: NOTIFICATION_ID

        Log.d(TAG, "Starting continuous 30s alarm for: $title ($taskId)")
        isServiceRunning = true

        createNotificationChannel()

        // 1. Build Full-Screen Intent for AlarmActivity
        val fullScreenIntent = Intent(this, AlarmActivity::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("title", title)
            putExtra("notes", notes)
            putExtra("notificationId", notificationId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            notificationId,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Stop Action Intent
        val stopIntent = Intent(this, AlarmService::class.java).apply {
            setAction("STOP_ALARM")
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            notificationId + 100,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("⏰ Lifemate Alarm: $title")
            .setContentText(if (notes.isNotEmpty()) notes else "Tap to open alarm controls")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setOngoing(true)
            .setAutoCancel(false)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent)
            .build()

        startForeground(NOTIFICATION_ID, notification)

        // 2. Start Looping Continuous Audio on ALARM Stream
        startAlarmSound()

        // 3. Start Looping Continuous Vibration
        startVibration()

        // 4. Set 30-Second Auto-Stop Timeout
        autoStopRunnable?.let { autoStopHandler?.removeCallbacks(it) }
        autoStopHandler = android.os.Handler(android.os.Looper.getMainLooper())
        autoStopRunnable = Runnable {
            Log.d(TAG, "30-second auto-stop timeout reached. Auto-stopping alarm.")
            stopAlarm()
            stopSelf()
        }
        autoStopHandler?.postDelayed(autoStopRunnable!!, 30000) // Exactly 30 seconds

        // 5. Launch Full Screen AlarmActivity directly
        try {
            startActivity(fullScreenIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch AlarmActivity directly: ${e.message}")
        }

        return START_STICKY
    }

    private fun startAlarmSound() {
        try {
            stopAlarmSound()
            var alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            if (alarmUri == null) {
                alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            }

            mediaPlayer = MediaPlayer().apply {
                setDataSource(applicationContext, alarmUri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = true
                prepare()
                start()
            }
            Log.d(TAG, "Continuous alarm audio started on USAGE_ALARM stream.")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting alarm sound: ${e.message}", e)
        }
    }

    private fun startVibration() {
        try {
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vm.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            val pattern = longArrayOf(0, 800, 400)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting vibration: ${e.message}")
        }
    }

    private fun stopAlarmSound() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
            mediaPlayer = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping media player: ${e.message}")
        }
    }

    private fun stopVibration() {
        try {
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping vibration: ${e.message}")
        }
    }

    private fun stopAlarm() {
        isServiceRunning = false
        autoStopRunnable?.let { autoStopHandler?.removeCallbacks(it) }
        autoStopHandler = null
        autoStopRunnable = null
        stopAlarmSound()
        stopVibration()
        stopForeground(STOP_FOREGROUND_REMOVE)
        Log.d(TAG, "AlarmService stopped cleanly.")
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Lifemate Clock Alarms",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Full-screen continuous alarms for Lifemate task reminders"
                setSound(null, null)
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
