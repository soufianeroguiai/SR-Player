import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/player_provider.dart';
import '../services/pip_service.dart';
import 'home/home_screen.dart';
import 'player/player_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    PipService.init();
    // فيديو يصل من تطبيق خارجي ("فتح باستخدام") والتطبيق مفتوح مسبقاً.
    PipService.onExternalVideo = _openExternal;
    // فيديو فُتح به التطبيق من الصفر.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await PipService.getInitialVideo();
      if (initial != null && mounted) _openExternal(initial);
    });
  }

  @override
  void dispose() {
    if (PipService.onExternalVideo == _openExternal) {
      PipService.onExternalVideo = null;
    }
    super.dispose();
  }

  Future<void> _openExternal(Map<String, String> data) async {
    final path = data['path'];
    if (path == null || path.isEmpty || !mounted) return;
    final rawName = data['name'];
    final name = (rawName == null || rawName.isEmpty)
        ? path.split('/').last
        : rawName;

    var size = 0;
    var modified = DateTime.now();
    try {
      final stat = File(path).statSync();
      size = stat.size;
      modified = stat.modified;
    } catch (_) {}

    final video = VideoItem(
      id: path,
      path: path,
      name: name,
      size: size,
      modified: modified,
      folder: '',
      duration: Duration.zero,
    );

    final provider = context.read<PlayerProvider>();
    // إن كان هناك فيديو مفتوح (كامل أو مصغّر) نغلقه أولاً حتى يُنشأ مشغّل نظيف.
    if (provider.currentVideo != null && !provider.isHidden) {
      provider.closePlayer();
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
    }
    // كل فتح للفيديو يمر عبر PlayerProvider.openVideo()
    context.read<PlayerProvider>().openVideo(video);
  }

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
