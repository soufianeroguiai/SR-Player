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
import 'app/permission_gate.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) => FlutterError.presentError(details);
  await _bootstrap();
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