import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pip_service.dart';
import '../services/subtitle_service.dart';
import '../widgets/subtitle_renderer.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Offset _position = const Offset(16, 100);

  double? _width;
  double _baseWidth = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    if (!provider.isMini || provider.controller == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    _width ??= screenSize.width * 0.50;

    if (_width! >= screenSize.width - 16) {
      _width = screenSize.width * 0.50;
    }

    final height = _width! * (9 / 16);

    final maxDx = (screenSize.width - _width!).clamp(0.0, double.infinity);
    final maxDy = (screenSize.height - height - kToolbarHeight).clamp(0.0, double.infinity);

    _position = Offset(
      _position.dx.clamp(0.0, maxDx),
      _position.dy.clamp(0.0, maxDy),
    );

    return ValueListenableBuilder<bool>(
      valueListenable: PipService.isInPipMode,
      builder: (context, isSystemPip, child) {
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

        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: widget.onTap,
            onScaleStart: (details) {
              _baseWidth = _width!;
            },
            onScaleUpdate: (details) {
              setState(() {
                _position += details.focalPointDelta;

                if (details.scale != 1.0) {
                  _width = (_baseWidth * details.scale).clamp(
                    150.0,
                    screenSize.width - 32.0,
                  );
                }
              });
            },
            child: _buildMiniPlayer(_width!, height, provider),
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer(double width, double height, PlayerProvider provider) {
    if (provider.player == null) return const SizedBox.shrink();

    final subtitleSettings = context.watch<SettingsProvider>().subtitleSettings;
    final videoSize = Size(width, height);

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
            Positioned.fill(
              child: Video(
                controller: provider.controller!,
                fit: BoxFit.cover,
                controls: NoVideoControls,
                subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
              ),
            ),

            Positioned.fill(
              child: ValueListenableBuilder<String?>(
                valueListenable: provider.currentSubtitleText,
                builder: (context, text, _) {
                  if (text == null || text.trim().isEmpty) return const SizedBox.shrink();
                  return SubtitleRenderer(
                    currentEntry: SubtitleEntry(
                      start: Duration.zero,
                      end: const Duration(hours: 1),
                      text: text,
                    ),
                    settings: subtitleSettings,
                    videoRect: Rect.fromLTWH(0, 0, width, height),
                    videoSize: videoSize,
                    screenSize: videoSize,
                    safeArea: EdgeInsets.zero,
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: StreamBuilder<bool>(
                stream: provider.player!.stream.playing,
                initialData: provider.player!.state.playing,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return GestureDetector(
                    onTap: () => isPlaying ? provider.player!.pause() : provider.player!.play(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 6,
              left: 6,
              child: GestureDetector(
                onTap: () => provider.closePlayer(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),

            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _width = (_width! + details.delta.dx).clamp(
                      150.0,
                      MediaQuery.of(context).size.width - _position.dx - 16,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}