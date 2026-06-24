import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// ══════════════════════════════════════════════
// الشريط العلوي — مبسّط: رجوع + اسم الفيديو + زرّا الصوت والترجمة
// ══════════════════════════════════════════════
class PlayerTopBar extends StatelessWidget {
  final String videoName;
  final VoidCallback onBack;
  final VoidCallback onAudioMenu;
  final VoidCallback onSubtitleMenu;
  final bool showSubtitles;
  // الخصائص التالية مُبقاة للتوافق لكن لم تعد تُظهر في TopBar
  final VoidCallback? onToggleFit;
  final VoidCallback? onToggleOrientation;
  final VoidCallback? onPip;
  final bool isLandscape;

  const PlayerTopBar({
    super.key,
    required this.videoName,
    required this.onBack,
    required this.onAudioMenu,
    required this.onSubtitleMenu,
    required this.showSubtitles,
    this.onToggleFit,
    this.onToggleOrientation,
    this.onPip,
    this.isLandscape = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.75), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              videoName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
              ),
            ),
          ),
          // زرّا الصوت والترجمة في الأعلى
          _TopIconBtn(
            icon: Symbols.graphic_eq_rounded,
            onTap: onAudioMenu,
          ),
          _TopIconBtn(
            icon: showSubtitles ? Symbols.subtitles_rounded : Symbols.subtitles_off_rounded,
            onTap: onSubtitleMenu,
            color: showSubtitles ? Colors.lightBlueAccent : Colors.white60,
          ),
        ]),
      ),
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _TopIconBtn({required this.icon, required this.onTap, this.color = Colors.white70});
  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onTap,
      );
}

// ══════════════════════════════════════════════
// الشريط السفلي الشامل
// ┌─────────────────────────────────────────┐
// │  00:31 ═══════●══════════════════ 23:35 │
// │    [PiP]  [◀10] [⏸] [10▶]  [Fit] [🔄] │
// └─────────────────────────────────────────┘
// ══════════════════════════════════════════════
class PlayerBottomBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final Color primaryColor;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleLock;
  final VoidCallback onPip;
  final VoidCallback onToggleOrientation;
  final bool isLandscape;

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
    required this.onToggleFit,
    required this.onToggleLock,
    required this.onPip,
    required this.onToggleOrientation,
    this.isLandscape = true,
  });

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // ── شريط التقدم الزمني ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(children: [
                Text(_fmt(position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.25),
                    ),
                    child: Slider(value: progress, onChanged: onSeek),
                  ),
                ),
                Text(_fmt(duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),

            // ── صف الأزرار ──
            SizedBox(
              height: 52,
              child: Row(children: [
                // ── الطرف الأيسر: PiP + قفل ──
                _BottomBtn(
                  icon: Symbols.picture_in_picture_rounded,
                  onTap: onPip,
                  size: 22,
                ),
                _BottomBtn(
                  icon: Symbols.lock_rounded,
                  onTap: onToggleLock,
                  size: 22,
                ),

                const Spacer(),

                // ── وسط: تأخير + play/pause + تقديم ──
                _BottomBtn(
                  icon: Symbols.replay_10_rounded,
                  onTap: onSkipBack,
                  size: 28,
                ),
                const SizedBox(width: 8),
                _PlayBtn(isPlaying: isPlaying, onTap: onPlayPause, color: primaryColor),
                const SizedBox(width: 8),
                _BottomBtn(
                  icon: Symbols.forward_10_rounded,
                  onTap: onSkipForward,
                  size: 28,
                ),

                const Spacer(),

                // ── الطرف الأيمن: تدوير + تكبير/تصغير فيديو ──
                _BottomBtn(
                  icon: isLandscape
                      ? Symbols.screen_rotation_rounded
                      : Symbols.stay_current_portrait_rounded,
                  onTap: onToggleOrientation,
                  size: 22,
                ),
                _BottomBtn(
                  icon: Symbols.aspect_ratio_rounded,
                  onTap: onToggleFit,
                  size: 22,
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final Color color;
  const _PlayBtn({required this.isPlaying, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
        ),
        child: Icon(
          isPlaying ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _BottomBtn({required this.icon, required this.onTap, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white70, size: size),
      ),
    );
  }
}

/// زر تحكم مستقل (مُبقى للتوافق مع استدعاءات قديمة)
class CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CtrlBtn(this.icon, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration:
              BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      );
}
