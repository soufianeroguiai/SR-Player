package com.sr.player

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.BatteryManager
import android.os.Build
import android.os.ParcelFileDescriptor
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.net.Uri
import android.util.Rational
import android.view.KeyEvent
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val pipChannelName = "com.splayer.app/pip"
    private var pipChannel: MethodChannel? = null

    // يعكس ما إذا كان هناك فيديو قيد التشغيل حالياً فـ Flutter، يُحدَّث
    // باستمرار من Dart عبر setPipEligible فكل مرة تتغيّر فيها حالة
    // التشغيل. نحتاجه هنا محلياً لأن onUserLeaveHint() يُستدعى من طرف
    // أندرويد مباشرة (بدون أي تأخير) ولا يقدر ينتظر رد Async قادم من Dart
    // فتلك اللحظة بالذات.
    private var pipEligible = false

    // عند تفعيل خيار "أزرار الصوت للتقديم" نعترض أزرار الصوت ونرسلها لـ Dart.
    private var interceptVolumeKeys = false

    // نُبقي واصف الملف مفتوحاً (للفيديوهات القادمة من content://) لأن
    // المسار /proc/self/fd/N يبقى صالحاً فقط ما دام الواصف مفتوحاً.
    private var openPfd: ParcelFileDescriptor? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannelName)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPip" -> {
                    result.success(enterPipMode())
                }
                "setPipEligible" -> {
                    pipEligible = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                "setInterceptVolumeKeys" -> {
                    interceptVolumeKeys = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                "getBatteryLevel" -> {
                    result.success(readBatteryLevel())
                }
                "getInitialVideo" -> {
                    val video = resolveVideo(intent)
                    // نُفرغ الـ intent حتى لا يُفتح الفيديو نفسه مرتين.
                    intent?.action = Intent.ACTION_MAIN
                    result.success(video)
                }
                "startPlaybackService" -> {
                    val title = call.arguments as? String ?: "SR Player"
                    startPlaybackService(title)
                    result.success(null)
                }
                "stopPlaybackService" -> {
                    stopPlaybackService()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        pipChannel = channel
    }

    // singleTop: فتح فيديو جديد والتطبيق مفتوح يصل هنا بدل إنشاء نشاط جديد.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val video = resolveVideo(intent)
        if (video != null) {
            intent.action = Intent.ACTION_MAIN
            pipChannel?.invokeMethod("onOpenVideo", video)
        }
    }

    private fun resolveVideo(intent: Intent?): Map<String, String>? {
        if (intent == null || intent.action != Intent.ACTION_VIEW) return null
        val uri: Uri = intent.data ?: return null
        return when (uri.scheme) {
            "file" -> {
                val path = uri.path ?: return null
                mapOf("path" to path, "name" to File(path).name)
            }
            "content" -> {
                val name = queryDisplayName(uri)
                val realPath = queryRealPath(uri)
                if (realPath != null) {
                    mapOf("path" to realPath, "name" to (name ?: File(realPath).name))
                } else {
                    try {
                        openPfd?.close()
                        val pfd = contentResolver.openFileDescriptor(uri, "r") ?: return null
                        openPfd = pfd
                        mapOf("path" to "/proc/self/fd/${pfd.fd}", "name" to (name ?: "video"))
                    } catch (e: Exception) {
                        null
                    }
                }
            }
            else -> null
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        return try {
            contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
                if (c.moveToFirst()) {
                    val idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (idx >= 0) c.getString(idx) else null
                } else null
            }
        } catch (e: Exception) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun queryRealPath(uri: Uri): String? {
        return try {
            contentResolver.query(uri, arrayOf(MediaStore.MediaColumns.DATA), null, null, null)?.use { c ->
                if (c.moveToFirst()) {
                    val idx = c.getColumnIndex(MediaStore.MediaColumns.DATA)
                    val p = if (idx >= 0) c.getString(idx) else null
                    if (!p.isNullOrEmpty() && File(p).canRead()) p else null
                } else null
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun readBatteryLevel(): Int {
        val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        return if (level >= 0 && scale > 0) (level * 100) / scale else -1
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (interceptVolumeKeys &&
            (event.keyCode == KeyEvent.KEYCODE_VOLUME_UP || event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)
        ) {
            if (event.action == KeyEvent.ACTION_DOWN) {
                val dir = if (event.keyCode == KeyEvent.KEYCODE_VOLUME_UP) 1 else -1
                pipChannel?.invokeMethod("onVolumeKey", dir)
            }
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    // نبدأ الخدمة الأمامية حتى يبقى الصوت شغّالاً بعد قفل الشاشة (أندرويد
    // يوقف العمليات فالخلفية بدون خدمة أمامية بعد مدة قصيرة من القفل).
    private fun startPlaybackService(title: String) {
        val intent = Intent(this, PlaybackService::class.java).apply {
            putExtra(PlaybackService.EXTRA_TITLE, title)
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun stopPlaybackService() {
        val intent = Intent(this, PlaybackService::class.java).apply {
            action = PlaybackService.ACTION_STOP
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun enterPipMode(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()
            return enterPictureInPictureMode(params)
        }
        return false
    }

    // هذه هي اللحظة الصحيحة لطلب الدخول لـ PiP على أندرويد: تُستدعى فوراً
    // ولحظة خروج المستخدم من التطبيق (زر الرئيسية، التبديل بين التطبيقات،
    // إيماءة الرجوع...) - قبل أي إيقاف مؤقت فعلي للنشاط (onPause).
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipEligible) {
            enterPipMode()
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        pipChannel?.invokeMethod("onPipModeChanged", isInPictureInPictureMode)
    }

    override fun onDestroy() {
        try { openPfd?.close() } catch (e: Exception) {}
        super.onDestroy()
    }
}
