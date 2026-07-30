package com.example.lifemate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import androidx.core.content.ContextCompat

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val taskId = intent.getStringExtra("taskId") ?: ""
        val title = intent.getStringExtra("title") ?: "Lifemate Alarm"
        val notes = intent.getStringExtra("notes") ?: ""
        val notificationId = intent.getIntExtra("notificationId", 0)

        Log.d(TAG, "Alarm triggered for task: $title ($taskId), notificationId: $notificationId")

        // Acquire temporary WakeLock to wake CPU
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "Lifemate:AlarmReceiverWakeLock"
        )
        wakeLock.acquire(10000)

        // Start native Foreground Alarm Service
        val serviceIntent = Intent(context, AlarmService::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("title", title)
            putExtra("notes", notes)
            putExtra("notificationId", notificationId)
            action = "START_ALARM"
        }

        try {
            ContextCompat.startForegroundService(context, serviceIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting AlarmService: ${e.message}", e)
        }
    }
}
