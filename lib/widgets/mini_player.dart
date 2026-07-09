import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends StatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Offset _position = const Offset(16, 100);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    if (!provider.isMini || provider.controller == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final miniWidth = screenSize.width * 0.4;
    final miniHeight = miniWidth * 0.6;

    return Positioned(
      left: _position.dx.clamp(0.0, screenSize.width - miniWidth),
      top: _position.dy.clamp(0.0, screenSize.height - miniHeight - kToolbarHeight),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: _buildMiniPlayer(miniWidth, miniHeight, provider),
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            setState(() {
              _position = Offset(
                details.offset.dx.clamp(0.0, screenSize.width - miniWidth),
                details.offset.dy.clamp(0.0, screenSize.height - miniHeight - kToolbarHeight),
              );
            });
          },
          child: _buildMiniPlayer(miniWidth, miniHeight, provider),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(double width, double height, PlayerProvider provider) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Video(
              key: ValueKey('mini_video_${provider.isMini}'),
              controller: provider.controller!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                provider.closeMiniPlayer(); // سيوقف كل شيء
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}