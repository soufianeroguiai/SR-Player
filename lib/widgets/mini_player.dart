import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pip_service.dart';
import '../widgets/subtitle_renderer.dart';
// تأكد من صحة مسار استيراد SubtitleEntry حسب هيكل مشروعك
import '../services/subtitle_service.dart'; 

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Offset _position = const Offset(16, 100);
  
  // متغيرات للتحكم الديناميكي بالحجم
  double? _width;
  double _baseWidth = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    if (!provider.isMini || provider.controller == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    // 1. تعيين العرض الافتراضي لأول مرة (50% من عرض الشاشة)
    _width ??= screenSize.width * 0.50;

    // 2. حماية: إذا تم تدوير الشاشة وأصبح العرض المحفوظ أكبر من الشاشة، نرجعه للحجم الافتراضي
    if (_width! >= screenSize.width - 16) {
      _width = screenSize.width * 0.50;
    }

    // 3. الحفاظ على أبعاد الفيديو (نسبة 16:9)
    final height = _width! * (9 / 16);

    // 4. حماية: حساب أقصى مساحة آمنة لتجنب الأخطاء (Crash) عند دوران الشاشة
    final maxDx = (screenSize.width - _width!).clamp(0.0, double.infinity);
    final maxDy = (screenSize.height - height - kToolbarHeight).clamp(0.0, double.infinity);

    // 5. منع المشغل من الخروج خارج حواف الشاشة
    _position = Offset(
      _position.dx.clamp(0.0, maxDx),
      _position.dy.clamp(0.0, maxDy),
    );

    return ValueListenableBuilder<bool>(
      valueListenable: PipService.isInPipMode,
      builder: (context, isSystemPip, child) {
        
        // 🔹 وضع "صورة داخل صورة" (PiP) الخاص بالنظام الخارجي
        if (isSystemPip) {
          return Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Video(
                controller: provider.controller!,
                fit: BoxFit.contain,
                controls: NoVideoControls,
              ),
            ),
          );
        }

        // 🔹 الوضع المصغر التفاعلي داخل التطبيق
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: widget.onTap, // استعادة الشاشة الكاملة عند الضغط
            
            // بدء السحب أو التكبير (بإصبعين)
            onScaleStart: (details) {
              _baseWidth = _width!;
            },
            
            // تحديث الحركة والحجم
            onScaleUpdate: (details) {
              setState(() {
                // تحريك المشغل
                _position += details.focalPointDelta;

                // تكبير/تصغير المشغل بقرصة الأصابع (Pinch)
                if (details.scale != 1.0) {
                  _width = (_baseWidth * details.scale).clamp(
                    150.0, // الحد الأدنى للعرض
                    screenSize.width - 32.0, // الحد الأقصى للعرض
                  );
                }
              });
            },
            child: _buildMiniPlayer(_width!, height, provider, context),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer(double width, double height, PlayerProvider provider, BuildContext context) {
    final player = provider.player;
    if (player == null) return const SizedBox.shrink();

    // جلب إعدادات الترجمة لتتحدث حياً مع المشغل المصغر
    final subtitleSettings = context.watch<SettingsProvider>().subtitleSettings;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // 1. الفيديو الأساسي
            Positioned.fill(
              child: Video(
                controller: provider.controller!,
                fit: BoxFit.cover,
                controls: NoVideoControls,
                // إخفاء الترجمة الافتراضية للنظام لتجنب التداخل
                subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
              ),
            ),

            // 2. الترجمة الحية المخصصة
            Positioned.fill(
              child: StreamBuilder<List<String>>(
                stream: player.stream.subtitle,
                builder: (context, snapshot) {
                  final text = snapshot.data?.join('\n') ?? '';
                  if (text.trim().isEmpty) return const SizedBox.shrink();

                  return SubtitleRenderer(
                    currentEntry: SubtitleEntry(
                      start: Duration.zero,
                      end: const Duration(hours: 1),
                      text: text,
                    ),
                    settings: subtitleSettings,
                    videoRect: Rect.fromLTWH(0, 0, width, height),
                    videoSize: Size(width, height),
                    screenSize: Size(width, height),
                    safeArea: EdgeInsets.zero,
                  );
                },
              ),
            ),

            // 3. طبقة الأزرار (تشغيل/إيقاف وإغلاق)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.2), // تظليل خفيف جداً
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر التشغيل/الإيقاف
                    StreamBuilder<bool>(
                      stream: player.stream.playing,
                      initialData: player.state.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 40,
                            ),
                            onPressed: () => isPlaying ? player.pause() : player.play(),
                          ),
                        );
                      },
                    ),
                    
                    // زر الإغلاق النهائي
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.9), size: 30),
                        onPressed: () => provider.closePlayer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. مقبض التكبير/التصغير بإصبع واحد (زاوية سفلية يمنى)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    // السحب لتغيير العرض (والطول يتغير تلقائياً للنسبة 16:9)
                    _width = (_width! + details.delta.dx).clamp(
                      150.0,
                      MediaQuery.of(context).size.width - _position.dx - 16,
                    );
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.transparent, // لالتقاط اللمس بسهولة
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
