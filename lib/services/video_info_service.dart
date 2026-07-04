import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';

class VideoInfo {
  final int width;
  final int height;
  final double fps;
  final String codec;
  final String pixelFormat;
  final String primaries;
  final String gamma;
  final String colorMatrix;
  final String light;
  final String chromaLocation;
  final String aspect;
  final bool isHDR;
  final bool isHEVC;
  final bool isAV1;
  final bool isVP9;
  final bool isH264;

  const VideoInfo({
    required this.width,
    required this.height,
    required this.fps,
    required this.codec,
    required this.pixelFormat,
    required this.primaries,
    required this.gamma,
    required this.colorMatrix,
    required this.light,
    required this.chromaLocation,
    required this.aspect,
    required this.isHDR,
    required this.isHEVC,
    required this.isAV1,
    required this.isVP9,
    required this.isH264,
  });

  String get resolutionText {
    if (is4K) return '4K Ultra HD';
    if (is2K) return '2K QHD';
    if (is1080p) return '1080p FHD';
    if (is720p) return '720p HD';
    return '${height}p';
  }

  bool get is480p => height <= 480;
  bool get is720p => height > 480 && height <= 720;
  bool get is1080p => height > 720 && height <= 1080;
  bool get is2K => height > 1080 && height <= 1440;
  bool get is4K => height > 1440;
}

class VideoInfoService {
  static Future<VideoInfo> read(Player player) async {
    final native = player.platform as NativePlayer;

    Future<String> safeGet(String property) async {
      try {
        final res = await native.getProperty(property);
        return res?.trim() ?? '';
      } catch (_) {
        return '';
      }
    }

    final results = await Future.wait([
      safeGet('video-codec'),
      safeGet('video-params/gamma'),
      safeGet('video-params/primaries'),
      safeGet('video-params/w'),
      safeGet('video-params/h'),
      safeGet('container-fps'),
      safeGet('video-params/pixelformat'),
      safeGet('video-params/colormatrix'),
      safeGet('video-params/light'),
      safeGet('video-params/chroma-location'),
      safeGet('video-params/aspect'),
    ]);

    final codec = results[0].toLowerCase();
    final gamma = results[1].toLowerCase();
    final primaries = results[2].toLowerCase();
    final width = int.tryParse(results[3]) ?? 0;
    final height = int.tryParse(results[4]) ?? 0;
    final fps = double.tryParse(results[5]) ?? 0;
    final pixelFormat = results[6].toLowerCase();
    final colorMatrix = results[7];
    final light = results[8];
    final chroma = results[9];
    final aspect = results[10];

    final is10bit = pixelFormat.contains('p10') || pixelFormat.contains('10bit');
    final hdr = primaries.contains('bt.2020') ||
        gamma.contains('pq') ||
        gamma.contains('hlg') ||
        (is10bit && (light.toLowerCase().contains('hdr') || gamma.contains('bt.2100')));

    return VideoInfo(
      width: width,
      height: height,
      fps: fps,
      codec: codec,
      pixelFormat: pixelFormat,
      primaries: primaries,
      gamma: gamma,
      colorMatrix: colorMatrix,
      light: light,
      chromaLocation: chroma,
      aspect: aspect,
      isHDR: hdr,
      isHEVC: codec.contains('hevc') || codec.contains('h265'),
      isAV1: codec.contains('av1'),
      isVP9: codec.contains('vp9'),
      isH264: codec.contains('h264') || codec.contains('avc'),
    );
  }
}