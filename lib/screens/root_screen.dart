import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import 'home/home_screen.dart';
import 'player/player_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeScreen(),
          // MiniPlayer صارت تُعرض على مستوى التطبيق كله (فـ main.dart) حتى
          // تبقى طافية فوق أي شاشة (الإعدادات، المفضلة...)، وليس فقط هنا.
          // هنا كنعرضو غير PlayerScreen الكاملة.
          Consumer<PlayerProvider>(
            builder: (context, provider, child) {
              if (provider.isHidden || provider.currentVideo == null || provider.isMini) {
                return const SizedBox.shrink();
              }
              return PlayerScreen(video: provider.currentVideo!);
            },
          ),
        ],
      ),
    );
  }
}