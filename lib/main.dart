import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'screens/root_screen.dart';
import 'widgets/mini_player.dart';
import 'app/permission_gate.dart';
import 'l10n/app_localizations.dart';

/// مفتاح تنقّل عام حتى نقدر نرجع لأول شاشة (RootScreen) من أي مكان فالتطبيق
/// - نحتاجه فـ MiniPlayer العامة: إيلا كان المستخدم فشاشة الإعدادات مثلاً
/// وضغط على المشغّل المصغّر باش يكبّرو، خاصنا نرجعو أولاً لـ RootScreen
/// (اللي فيه PlayerScreen) قبل ما نكبّر، وإلا التكبير غايوقع فالخلفية بلا
/// ما يبان.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// سجلّ الأخطاء العام: نجمّع فيه أي استثناء غير ملتقَط (سواء أثناء البناء
/// أو داخل Future/Timer/callback) باش نعرضو مباشرة فوق الواجهة. فـ release
/// mode، فلاتر عادةً ما يعرضش الشاشة الحمراء ولا يوقف التطبيق - الخطأ
/// كيختفي بصمت فـ logcat اللي ما عندناش وصول ليه من الهاتف. هاذ الحل كيبان
/// مباشرة فالتطبيق نفسه.
final ValueNotifier<List<String>> globalErrorLog = ValueNotifier<List<String>>([]);

void _logGlobalError(Object error, StackTrace? stack) {
  final entry = '$error\n${stack ?? ''}';
  // كنحتفظو بآخر 5 أخطاء فقط باش ما يتقلش السجلّ بلا حدود.
  final updated = [...globalErrorLog.value, entry];
  globalErrorLog.value = updated.length > 5 ? updated.sublist(updated.length - 5) : updated;
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logGlobalError(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _logGlobalError(error, stack);
      return true;
    };
    await _bootstrap();
  }, (error, stack) {
    _logGlobalError(error, stack);
  });
}

/// كل منطق التهيئة الفعلي، معزول فدالة مستقلة حتى يمكن استدعاؤه من جديد
/// عند الضغط على "إعادة المحاولة" فـ [ErrorApp] بدل استدعاء main() نفسها
/// (استدعاء نقطة الدخول من داخل التطبيق غير صحيح مفاهيمياً ولا ضروري).
Future<void> _bootstrap() async {
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    runApp(ErrorApp(kind: _InitErrorKind.mediaKit, rawError: '$e'));
    return;
  }

  try {
    await FFmpegKitExtended.initialize();
  } catch (e) {
    runApp(ErrorApp(kind: _InitErrorKind.ffmpeg, rawError: '$e'));
    return;
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  SettingsProvider settings;
  try {
    settings = SettingsProvider();
    await settings.load();
  } catch (e) {
    runApp(ErrorApp(kind: _InitErrorKind.settings, rawError: '$e'));
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const SPlayerApp(),
    ),
  );
}

class SPlayerApp extends StatelessWidget {
  const SPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'SR Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seed: settings.themeSeedColor),
      darkTheme: AppTheme.dark(seed: settings.themeSeedColor),
      themeMode: settings.themeMode,
      locale: settings.appLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PermissionGate(
        child: RootScreen(),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // المشغّل المصغّر أصبح هنا على مستوى التطبيق كله (فوق أي Route)
            // بدل داخل RootScreen فقط. سابقاً كان أي Navigator.push (فتح
            // الإعدادات مثلاً) يغطي الشاشة بالكامل ويُخفي المشغّل المصغّر
            // بصرياً رغم أنه لم يُغلق فعلياً. الآن يبقى طافياً فوق أي شاشة.
            const _GlobalMiniPlayer(),
            const _GlobalErrorOverlay(),
          ],
        );
      },
    );
  }
}

/// غلاف بسيط يعرض MiniPlayer على مستوى التطبيق، ويهتم بالرجوع لـ
/// RootScreen عند الضغط على المشغّل المصغّر من أي شاشة أخرى غير الرئيسية.
class _GlobalMiniPlayer extends StatelessWidget {
  const _GlobalMiniPlayer();

  @override
  Widget build(BuildContext context) {
    return MiniPlayer(
      onTap: () {
        // نرجع أولاً لأول شاشة (RootScreen) - وإلا كبّرنا المشغّل والمستخدم
        // مازال واقف فشاشة الإعدادات مثلاً، فما غايبانش التكبير.
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        context.read<PlayerProvider>().maximize();
      },
    );
  }
}

/// شريط أسفل الشاشة يظهر تلقائياً عند وقوع أي استثناء، مع نص الخطأ كاملاً
/// وزر نسخ. يبقى فوق أي شاشة (بما فيها المشغّل) لأنه مضاف عبر
/// MaterialApp.builder، وهو معزول تماماً عن أي Provider حتى ما يتأثرش
/// بأي مشكلة فالشجرة الرئيسية.
class _GlobalErrorOverlay extends StatelessWidget {
  const _GlobalErrorOverlay();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: globalErrorLog,
      builder: (context, errors, _) {
        if (errors.isEmpty) return const SizedBox.shrink();
        final latest = errors.last;
        return Positioned(
          left: 8,
          right: 8,
          bottom: 24,
          child: SafeArea(
            child: Material(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('خطأ (${errors.length})',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                          onPressed: () => Clipboard.setData(ClipboardData(text: errors.join('\n\n---\n\n'))),
                          tooltip: 'نسخ',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                          onPressed: () => globalErrorLog.value = [],
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          latest,
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _InitErrorKind { mediaKit, ffmpeg, settings }

class ErrorApp extends StatelessWidget {
  final _InitErrorKind kind;
  final String rawError;
  const ErrorApp({required this.kind, required this.rawError, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        final t = AppLocalizations.of(context)!;
        final message = switch (kind) {
          _InitErrorKind.mediaKit => t.mediaKitInitError(rawError),
          _InitErrorKind.ffmpeg => t.ffmpegInitError(rawError),
          _InitErrorKind.settings => t.settingsLoadError(rawError),
        };
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(t.errorOccurredTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(message,
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _bootstrap(),
                  icon: const Icon(Icons.refresh),
                  label: Text(t.retryButton),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }
}