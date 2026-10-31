package com.habitforce.habit_force

import android.content.Intent
import android.os.Bundle
import com.habitforce.habit_force.alarm.AlarmActivity
import com.habitforce.habit_force.alarm.AlarmRingService
import com.habitforce.habit_force.bridge.NativeChannel
import com.habitforce.habit_force.notify.Notifier
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeChannel(this, flutterEngine.dartExecutor.binaryMessenger).register()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Notifier.ensureChannels(this)
    }

    override fun onResume() {
        super.onResume()
        // Without notification permission Android may not show the alarm
        // screen; opening the app while it rings is then the way to it
        // (alarms HLD, *Notifications off*).
        if (AlarmRingService.isRinging) startActivity(Intent(this, AlarmActivity::class.java))
    }
}
