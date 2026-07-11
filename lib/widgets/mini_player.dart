import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pip_service.dart';
import '../widgets/subtitle_renderer.dart';
// تأكد من استيراد الكلاس SubtitleEntry من مساره الصحيح لديك (مثلاً من services أو models)

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Offset _position = const Offset(16, 100);
  
  // 👈 متغيرات جديدة للتحكم الديناميكي بالحجم
  double? _width;
  double _baseWidth = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    if (!provider.isMini || provider.controller == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    // 1. تعيين العرض الافتراضي لأول مرة فقط (مثلاً 50% من الشاشة)
    _width ??= screenSize.width * 0.50;

    // 2. الحفاظ على أبعاد الفيديو (16:9)
    final height = _width! * (9 / 16);

    // 3. منع المشغل من الخروج خارج حواف الشاشة أثناء التحريك أو التكبير
    _position = Offset(
      _position.dx.clamp(0.0, screenSize.width - _width!),
      _position.dy.clamp(0.0, screenSize.height - height - kToolbarHeight),
    );

    return ValueListenableBuilder<bool>(
      valueListenable: PipService.isInPipMode,
      builder: (context, isSystemPip, child) {
        
        // وضع PiP النظام
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

        // الوضع المصغر التفاعلي داخل التطبيق
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: widget.onTap, // التكبير واستعادة الشاشة الكاملة عند الضغط
            
            // 👈 بدء السحب أو التكبير
            onScaleStart: (details) {
              _baseWidth = _width!;
            },
            
            // 👈 تحديث الحركة والحجم
            onScaleUpdate: (details) {
              setState(() {
                // 1. تحريك المشغل (بإصبع واحد)
                _position += details.focalPointDelta;

                // 2. تكبير/تصغير المشغل (بإصبعين - Pinch)
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
                    // ملاحظة: تأكد من تمرير SubtitleEntry بطريقتك الصحيحة
                    currentEntry: null, // عدّل هذا السطر ليتوافق مع كلاس SubtitleEntry الخاص بك، أو استخدم النص مباشرة
                    settings: subtitleSettings,
                    videoRect: Rect.fromLTWH(0, 0, width, height),
                    videoSize: Size(width, height),
                    screenSize: Size(width, height),
                    safeArea: EdgeInsets.zero,
                  );
                },
              ),
            ),

            // 3. الأزرار (تشغيل وإغلاق)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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

            // 👈 4. مقبض التكبير/التصغير بإصبع واحد (في الزاوية السفلية اليمنى)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    // سحب الزاوية يكبر أو يصغر العرض (والطول يتغير تلقائياً بسبب النسبة 16:9)
                    _width = (_width! + details.delta.dx).clamp(
                      150.0,
                      MediaQuery.of(context).size.width - _position.dx - 16,
                    );
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.transparent, // منطقة شفافة لالتقاط اللمس
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.open_in_full_rounded, // أيقونة التوسيع
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
