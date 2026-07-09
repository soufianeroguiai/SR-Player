import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import 'home/home_screen.dart';
import 'player/player_screen.dart';
import '../widgets/mini_player.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeScreen(),
          Consumer<PlayerProvider>(
            builder: (context, provider, child) {
              if (provider.isHidden || provider.currentVideo == null) {
                return const SizedBox.shrink();
              }

              if (provider.isMini) {
                return MiniPlayer(
                  onTap: () {
                    provider.maximize();
                  },
                );
              }

              return PlayerScreen(video: provider.currentVideo!);
            },
          ),
        ],
      ),
    );
  }
}