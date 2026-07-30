package com.example.lifemate

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast

class AlarmActivity : Activity() {

    private var taskId: String = ""
    private var title: String = ""
    private var notes: String = ""
    private var notificationId: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ensure activity displays over lock screen and turns screen on
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        taskId = intent?.getStringExtra("taskId") ?: ""
        title = intent?.getStringExtra("title") ?: "Task Reminder"
        notes = intent?.getStringExtra("notes") ?: ""
        notificationId = intent?.getIntExtra("notificationId", 99991) ?: 99991

        // Build UI programmatically
        val rootLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#0F172A")) // Deep dark slate background
            setPadding(48, 64, 48, 64)
        }

        // Alarm Bell Emoji / Icon
        val iconView = TextView(this).apply {
            text = "⏰"
            textSize = 64f
            gravity = Gravity.CENTER
        }
        rootLayout.addView(iconView)

        // Subtitle header
        val headerView = TextView(this).apply {
            text = "LIFEMATE ALARM"
            textSize = 14f
            setTextColor(Color.parseColor("#94A3B8"))
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 16, 0, 8)
        }
        rootLayout.addView(headerView)

        // Task Title
        val titleView = TextView(this).apply {
            text = title
            textSize = 26f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, 8, 0, 8)
        }
        rootLayout.addView(titleView)

        // Task Notes
        if (notes.isNotEmpty()) {
            val notesView = TextView(this).apply {
                text = notes
                textSize = 16f
                setTextColor(Color.parseColor("#CBD5E1"))
                gravity = Gravity.CENTER
                setPadding(0, 8, 0, 24)
            }
            rootLayout.addView(notesView)
        } else {
            val spacer = TextView(this).apply { setPadding(0, 16, 0, 16) }
            rootLayout.addView(spacer)
        }

        // Action Buttons Container
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = 32
            }
        }

        // ⏹️ STOP BUTTON
        val stopButton = Button(this).apply {
            text = "⏹️ STOP ALARM"
            textSize = 18f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#EF4444")) // Crimson Red
                cornerRadius = 32f
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(56)
            ).apply {
                bottomMargin = 16
            }
            setOnClickListener {
                stopAlarm()
                Toast.makeText(this@AlarmActivity, "Alarm stopped", Toast.LENGTH_SHORT).show()
                finish()
            }
        }
        buttonLayout.addView(stopButton)

        // ⏰ SNOOZE (10m) BUTTON
        val snoozeButton = Button(this).apply {
            text = "⏰ SNOOZE (10 MIN)"
            textSize = 18f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#3B82F6")) // Royal Blue
                cornerRadius = 32f
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dpToPx(56)
            )
            setOnClickListener {
                stopAlarm()
                snoozeAlarm(10)
                Toast.makeText(this@AlarmActivity, "Alarm snoozed for 10 minutes", Toast.LENGTH_SHORT).show()
                finish()
            }
        }
        buttonLayout.addView(snoozeButton)

        rootLayout.addView(buttonLayout)
        setContentView(rootLayout)
    }

    private fun stopAlarm() {
        val stopIntent = Intent(this, AlarmService::class.java).apply {
            action = "STOP_ALARM"
        }
        startService(stopIntent)
    }

    private fun snoozeAlarm(minutes: Int) {
        val snoozeTimeMs = System.currentTimeMillis() + (minutes * 60 * 1000)
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

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

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, snoozeTimeMs, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, snoozeTimeMs, pendingIntent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }
}
