package com.example.lifemate

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val BATTERY_CHANNEL = "com.example.lifemate/battery"
    private val ALARM_CHANNEL = "com.example.lifemate/alarm_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Battery Optimization MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val ignoring = pm.isIgnoringBatteryOptimizations(packageName)
                    result.success(ignoring)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        val intent = Intent(android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(null)
                        } catch (e2: Exception) {
                            result.error("UNAVAILABLE", "Cannot open battery settings: ${e2.message}", null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 2. Native AlarmManager MethodChannel for Real Clock Alarms
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    try {
                        val taskId = call.argument<String>("taskId") ?: ""
                        val title = call.argument<String>("title") ?: "Task Reminder"
                        val notes = call.argument<String>("notes") ?: ""
                        val scheduledTimeMs = call.argument<Long>("scheduledTimeMs") ?: 0L
                        val notificationId = call.argument<Int>("notificationId") ?: 0

                        val success = scheduleNativeAlarm(taskId, title, notes, scheduledTimeMs, notificationId)
                        result.success(success)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error scheduling native alarm: ${e.message}", e)
                        result.error("ALARM_ERROR", e.message, null)
                    }
                }
                "cancelAlarm" -> {
                    try {
                        val notificationId = call.argument<Int>("notificationId") ?: 0
                        cancelNativeAlarm(notificationId)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                "stopAlarm" -> {
                    try {
                        val stopIntent = Intent(this, AlarmService::class.java).apply {
                            action = "STOP_ALARM"
                        }
                        startService(stopIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("STOP_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleNativeAlarm(
        taskId: String,
        title: String,
        notes: String,
        scheduledTimeMs: Long,
        notificationId: Int
    ): Boolean {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Cancel any pre-existing alarm for this notification ID to prevent duplicate alarms
        cancelNativeAlarm(notificationId)

        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("title", title)
            putExtra("notes", notes)
            putExtra("notificationId", notificationId)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        Log.d("MainActivity", "Scheduling Native Alarm for task '$title' at $scheduledTimeMs (ID: $notificationId)")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w("MainActivity", "canScheduleExactAlarms is FALSE. Prompting user for permission...")
                try {
                    val settingsIntent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                        data = Uri.parse("package:$packageName")
                    }
                    startActivity(settingsIntent)
                } catch (e: Exception) {
                    Log.e("MainActivity", "Failed to open exact alarm settings: ${e.message}")
                }
            }
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val alarmClockInfo = AlarmManager.AlarmClockInfo(scheduledTimeMs, pendingIntent)
                alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, scheduledTimeMs, pendingIntent)
            }
            Log.d("MainActivity", "SUCCESS: Native Alarm setAlarmClock registered for ID $notificationId at $scheduledTimeMs")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error in setAlarmClock: ${e.message}", e)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, scheduledTimeMs, pendingIntent)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, scheduledTimeMs, pendingIntent)
                }
                Log.d("MainActivity", "SUCCESS: Fallback setExactAndAllowWhileIdle registered for ID $notificationId")
            } catch (e2: Exception) {
                Log.e("MainActivity", "Fallback scheduling failed: ${e2.message}", e2)
                return false
            }
        }
        return true
    }

    private fun cancelNativeAlarm(notificationId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            Log.d("MainActivity", "Cancelled pending native alarm ID: $notificationId")
        }

        // Also stop active service if currently ringing
        if (AlarmService.isServiceRunning) {
            val stopIntent = Intent(this, AlarmService::class.java).apply {
                action = "STOP_ALARM"
            }
            startService(stopIntent)
        }
    }
}
