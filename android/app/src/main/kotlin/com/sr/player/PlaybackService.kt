package com.sr.player

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

/// خدمة أمامية (Foreground Service) بسيطة، دورها الوحيد هو إبقاء عملية
/// التطبيق حيّة أثناء التشغيل حتى بعد قفل الشاشة. بدون خدمة أمامية،
/// أندرويد (خصوصاً فوضع Doze الحديث) يوقف العمليات فالخلفية بعد مدة
/// قصيرة من قفل الشاشة، فيتوقف الصوت معها. الإشعار المصاحب إلزامي من
/// طرف أندرويد لأي خدمة أمامية من نوع mediaPlayback، ولا يمكن الاستغناء
/// عنه.
class PlaybackService : Service() {
    companion object {
        const val CHANNEL_ID = "sr_player_playback_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_STOP = "com.sr.player.action.STOP_PLAYBACK"
        const val EXTRA_TITLE = "title"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        val title = intent?.getStringExtra(EXTRA_TITLE) ?: "SR Player"
        createNotificationChannel()
        val notification = buildNotification(title)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // START_STICKY: نطلب من أندرويد إعادة تشغيل الخدمة تلقائياً إذا
        // قُتلت (فحالات نادرة جداً)، حتى يبقى الصوت مستمراً.
        return START_STICKY
    }

    private fun buildNotification(title: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText("جارٍ التشغيل")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تشغيل الفيديو فالخلفية",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
