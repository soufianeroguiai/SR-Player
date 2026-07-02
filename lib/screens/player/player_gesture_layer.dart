import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/settings_provider.dart';
import 'player_indicators.dart';

enum GestureType { none, seek, volume, brightness, subtitle }

class PlayerGestureLayer extends StatefulWidget {
  final Player player;
  final bool isLocked;
  final double volumeLevel;
  final ValueNotifier<double> brightnessNotifier;
  final ValueNotifier<double> seekMsNotifier;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isSpeedBoosted;
  final VoidCallback onToggleControls;
  final void Function(double newVolume) onVolumeChanged;
  final VoidCallback onPlayPause;
  final VoidCallback? onLongPressSpeedStart;
  final VoidCallback? onLongPressSpeedEnd;
  final Widget child;

  const PlayerGestureLayer({
    super.key,
    required this.player,
    required this.isLocked,
    required this.volumeLevel,
    required this.brightnessNotifier,
    required this.seekMsNotifier,
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.isSpeedBoosted = false,
    required this.onToggleControls,
    required this.onVolumeChanged,
    required this.onPlayPause,
    this.onLongPressSpeedStart,
    this.onLongPressSpeedEnd,
    required this.child,
  });

  @override
  State<PlayerGestureLayer> createState() => _PlayerGestureLayerState();
}

class _PlayerGestureLayerState extends State<PlayerGestureLayer> {
  double _startSubtitleSize = 24.0;
  double _startSubtitleScale = 1.0;
  double _startBottomPadding = 0.0;
  Offset _startFocalPoint = Offset.zero;
  bool _subtitleGestureActive = false;

  final ValueNotifier<bool> _showVolNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showBrightNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showSeekNotifier = ValueNotifier(false);
  Timer? _indicatorTimer;

  int? _hintSeconds;
  Timer? _seekHintTimer;

  GestureType _activeGesture = GestureType.none;
  Offset _startPanOffset = Offset.zero;
  bool _isPanLocked = false;

  @override
  void dispose() {
    _showVolNotifier.dispose();
    _showBrightNotifier.dispose();
    _showSeekNotifier.dispose();
    _indicatorTimer?.cancel();
    _seekHintTimer?.cancel();
    super.dispose();
  }

  void _resetIndicatorTimer() {
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(seconds: 1), () {
      _showVolNotifier.value = false;
      _showBrightNotifier.value = false;
    });
  }

  void _showSeekHint(int seconds) {
    setState(() => _hintSeconds = seconds);
    _seekHintTimer?.cancel();
    _seekHintTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hintSeconds = null);
    });
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final s = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onToggleControls,
          onDoubleTapDown: widget.isLocked
              ? null
              : (details) {
                  final seekSeconds = s.doubleTapSeekSeconds;
                  final x = details.localPosition.dx;
                  if (x < screenWidth / 3) {
                    final target = widget.position - Duration(seconds: seekSeconds);
                    widget.player.seek(target.isNegative ? Duration.zero : target);
                    _showSeekHint(-seekSeconds);
                  } else if (x > screenWidth * 2 / 3) {
                    final target = widget.position + Duration(seconds: seekSeconds);
                    widget.player.seek(target > widget.duration ? widget.duration : target);
                    _showSeekHint(seekSeconds);
                  } else {
                    widget.onPlayPause();
                  }
                },
          onLongPressStart: widget.isLocked || !s.longPressSpeedEnabled
              ? null
              : (_) => widget.onLongPressSpeedStart?.call(),
          onLongPressEnd: widget.isLocked || !s.longPressSpeedEnabled
              ? null
              : (_) => widget.onLongPressSpeedEnd?.call(),
          onLongPressCancel: widget.isLocked || !s.longPressSpeedEnabled
              ? null
              : () => widget.onLongPressSpeedEnd?.call(),
          onScaleStart: (details) {
            if (widget.isLocked) return;
            final sub = s.subtitleSettings;

            _activeGesture = GestureType.none;
            _isPanLocked = false;
            _startPanOffset = details.focalPoint;

            if (details.pointerCount == 3) {
              _startSubtitleScale = sub.subtitleScale;
              _activeGesture = GestureType.subtitle;
              return;
            }
            if (details.pointerCount == 2 && !widget.isPlaying) {
              _startSubtitleSize = sub.fontSize;
              _startBottomPadding = sub.bottomMargin;
              _startFocalPoint = details.focalPoint;
              _activeGesture = GestureType.subtitle;
              _subtitleGestureActive = true;
            } else {
              widget.seekMsNotifier.value = widget.position.inMilliseconds.toDouble();
              _subtitleGestureActive = false;
            }
          },
          onScaleUpdate: (details) {
            if (widget.isLocked) return;
            final sub = s.subtitleSettings;

            if (details.pointerCount == 3 && _activeGesture == GestureType.subtitle) {
              final newScale = (_startSubtitleScale * details.scale).clamp(0.5, 3.0);
              s.updateSubtitleSettings(sub.copyWith(subtitleScale: newScale));
              return;
            }
            if (details.pointerCount == 2 && _activeGesture == GestureType.subtitle && !widget.isPlaying) {
              final newSize = (_startSubtitleSize * details.scale).clamp(10.0, 150.0);
              s.updateSubtitleSettings(sub.copyWith(fontSize: newSize));
              final dy = details.focalPoint.dy - _startFocalPoint.dy;
              final newPadding = (_startBottomPadding - dy).clamp(0.0, screenHeight * 0.85);
              s.updateSubtitleSettings(sub.copyWith(bottomMargin: newPadding));
              return;
            }

            if (details.pointerCount != 1 || _activeGesture == GestureType.subtitle) return;
            if (details.focalPointDelta.distance < 0.5) return;

            if (!_isPanLocked) {
              final totalDx = (details.focalPoint.dx - _startPanOffset.dx).abs();
              final totalDy = (details.focalPoint.dy - _startPanOffset.dy).abs();

              if (totalDx > 10 || totalDy > 10) {
                _isPanLocked = true;
                if (totalDx > totalDy) {
                  _activeGesture = GestureType.seek;
                } else {
                  _activeGesture = details.focalPoint.dx > screenWidth / 2
                      ? GestureType.volume
                      : GestureType.brightness;
                }
              }
            }

            if (_isPanLocked) {
              if (_activeGesture == GestureType.seek) {
                final seekFactor = (widget.duration.inMilliseconds * 0.25).clamp(30000.0, 600000.0);
                final change = (details.focalPointDelta.dx / screenWidth) * seekFactor;
                widget.seekMsNotifier.value = (widget.seekMsNotifier.value + change)
                    .clamp(0.0, widget.duration.inMilliseconds.toDouble());
                _showSeekNotifier.value = true;
                _showVolNotifier.value = false;
                _showBrightNotifier.value = false;
              } else if (_activeGesture == GestureType.volume) {
                final delta = -details.focalPointDelta.dy / 180.0 * s.gestureSensitivity;
                widget.onVolumeChanged(widget.volumeLevel + delta);
                _showVolNotifier.value = true;
                _showBrightNotifier.value = false;
                _showSeekNotifier.value = false;
                _resetIndicatorTimer();
              } else if (_activeGesture == GestureType.brightness) {
                final delta = -details.focalPointDelta.dy / 180.0 * s.gestureSensitivity;
                final newBright = (widget.brightnessNotifier.value + delta).clamp(0.05, 1.0);
                widget.brightnessNotifier.value = newBright;
                ScreenBrightness.instance.setApplicationScreenBrightness(newBright);
                _showBrightNotifier.value = true;
                _showVolNotifier.value = false;
                _showSeekNotifier.value = false;
                _resetIndicatorTimer();
              }
            }
          },
          onScaleEnd: (details) {
            if (widget.isLocked) return;

            if (_showSeekNotifier.value) {
              widget.player.seek(Duration(milliseconds: widget.seekMsNotifier.value.toInt()));
              _showSeekNotifier.value = false;
            }

            _subtitleGestureActive = false;
            _activeGesture = GestureType.none;
            _isPanLocked = false;
          },
          child: widget.child,
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _showSeekNotifier,
          builder: (context, show, _) {
            if (!show) return const SizedBox.shrink();
            return ValueListenableBuilder<double>(
              valueListenable: widget.seekMsNotifier,
              builder: (context, seekMs, _) {
                final isForward = widget.seekMsNotifier.value > widget.position.inMilliseconds;
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.primary.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        isForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                        color: cs.primary,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fmt(Duration(milliseconds: seekMs.toInt())),
                        style: TextStyle(color: cs.primary, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _showVolNotifier,
          builder: (context, show, _) {
            if (!show) return const SizedBox.shrink();
            final isBoosted = widget.volumeLevel > 1.0;
            return Positioned(
              left: 20,
              top: screenHeight * 0.22,
              child: PlayerIndicators.buildFloatingIndicator(
                icon: widget.volumeLevel == 0
                    ? Icons.volume_off_rounded
                    : isBoosted
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded,
                displayValue: (widget.volumeLevel / 2.0).clamp(0.0, 1.0),
                labelText: '${(widget.volumeLevel * 100).round()}%',
                color: isBoosted ? const Color(0xFFFF8A65) : const Color(0xFF64B5F6),
              ),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _showBrightNotifier,
          builder: (context, show, _) {
            if (!show) return const SizedBox.shrink();
            return ValueListenableBuilder<double>(
              valueListenable: widget.brightnessNotifier,
              builder: (context, brightness, _) {
                return Positioned(
                  right: 20,
                  top: screenHeight * 0.22,
                  child: PlayerIndicators.buildFloatingIndicator(
                    icon: brightness < 0.15
                        ? Icons.brightness_2_rounded
                        : brightness < 0.5
                            ? Icons.brightness_5_rounded
                            : Icons.brightness_7_rounded,
                    displayValue: brightness,
                    labelText: '${(brightness * 100).round()}%',
                    color: const Color(0xFFFFF176),
                  ),
                );
              },
            );
          },
        ),

        if (_hintSeconds != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: cs.primary.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hintSeconds! > 0 ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                    color: cs.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_hintSeconds! > 0 ? "+" : ""}${_hintSeconds}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (widget.isSpeedBoosted)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.primary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.fast_forward_rounded, color: cs.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${s.longPressSpeedValue.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}