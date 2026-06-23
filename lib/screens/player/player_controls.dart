import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'player_fit_mode.dart';

class PlayerTopBar extends StatelessWidget {
  final String videoName;
  final VoidCallback onBack;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleOrientation;
  final VoidCallback onPip;
  final VoidCallback onAudioMenu;
  final VoidCallback onSubtitleMenu;
  final bool isLandscape;
  final bool showSubtitles;
  final bool hideFitAndPip;

  const PlayerTopBar({
    super.key,
    required this.videoName,
    required this.onBack,
    required this.onToggleFit,
    required this.onToggleOrientation,
    required this.onPip,
    required this.onAudioMenu,
    required this.onSubtitleMenu,
    required this.isLandscape,
    required this.showSubtitles,
    this.hideFitAndPip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
      ),
      child: SafeArea(
        child: Row(children: [
          IconButton(
              icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
              onPressed: onBack),
          Expanded(
              child: Text(videoName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
          if (!hideFitAndPip) ...[
            IconButton(
                icon: const Icon(Symbols.aspect_ratio_rounded, color: Colors.white70),
                onPressed: onToggleFit),
            IconButton(
                icon: Icon(
                    isLandscape
                        ? Symbols.screen_rotation_rounded
                        : Symbols.stay_current_portrait_rounded,
                    color: Colors.white70),
                onPressed: onToggleOrientation),
            IconButton(
                icon: const Icon(Symbols.picture_in_picture_rounded, color: Colors.white70),
                onPressed: onPip),
          ],
          IconButton(
              icon: const Icon(Symbols.graphic_eq_rounded, color: Colors.white70),
              onPressed: onAudioMenu),
          IconButton(
              icon: Icon(
                  showSubtitles
                      ? Symbols.subtitles_rounded
                      : Symbols.subtitles_off_rounded,
                  color: showSubtitles ? Colors.lightBlue : Colors.white54),
              onPressed: onSubtitleMenu),
        ]),
      ),
    );
  }
}

class PlayerBottomBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final Color primaryColor;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;
  final VideoFitMode fitMode;
  final VoidCallback onToggleFit;
  final VoidCallback onPip;
  final bool isLandscape;
  final VoidCallback onToggleOrientation;

  const PlayerBottomBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.primaryColor,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipBack,
    required this.onSkipForward,
    required this.fitMode,
    required this.onToggleFit,
    required this.onPip,
    required this.isLandscape,
    required this.onToggleOrientation,
  });

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  IconData _fitIcon() {
    switch (fitMode) {
      case VideoFitMode.contain:
        return Symbols.aspect_ratio_rounded;
      case VideoFitMode.cover:
        return Symbols.fullscreen_rounded;
      case VideoFitMode.fill:
        return Symbols.fit_screen_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.85), Colors.transparent]),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط التقدّم نحيف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(children: [
                Text(_fmt(position), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: primaryColor,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10)),
                    child: Slider(
                      value: duration.inMilliseconds > 0
                          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: onSeek,
                    ),
                  ),
                ),
                Text(_fmt(duration), style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ]),
            ),
            // صف الأزرار (صغير جداً)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // fit
                  IconButton(
                    icon: Icon(_fitIcon(), color: Colors.white70, size: 20),
                    onPressed: onToggleFit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  // PiP
                  IconButton(
                    icon: const Icon(Symbols.picture_in_picture_rounded, color: Colors.white70, size: 20),
                    onPressed: onPip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  // -10s
                  IconButton(
                    icon: const Icon(Symbols.replay_10_rounded, color: Colors.white, size: 22),
                    onPressed: onSkipBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  // play/pause (حلقة بيضاء)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: onPlayPause,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // +10s
                  IconButton(
                    icon: const Icon(Symbols.forward_10_rounded, color: Colors.white, size: 22),
                    onPressed: onSkipForward,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  // orientation
                  IconButton(
                    icon: Icon(
                        isLandscape ? Symbols.screen_rotation_rounded : Symbols.stay_current_portrait_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: onToggleOrientation,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}