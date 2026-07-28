import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SubtitleResult {
  final String id;
  final String fileName;
  final String language;
  final String downloadUrl;
  final double rating;
  final int downloadCount;

  SubtitleResult({
    required this.id,
    required this.fileName,
    required this.language,
    required this.downloadUrl,
    required this.rating,
    required this.downloadCount,
  });

  factory SubtitleResult.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    return SubtitleResult(
      id: json['id'],
      fileName: attrs['release'] ?? attrs['filename'] ?? 'unknown',
      language: attrs['language'] ?? 'unknown',
      downloadUrl: (attrs['files'] as List?)?.isNotEmpty == true
          ? attrs['files'][0]['file_url'] ?? ''
          : '',
      rating: (attrs['ratings']?.toDouble() ?? 0.0),
      downloadCount: attrs['download_count'] ?? 0,
    );
  }
}

/// يُرمى هذا الاستثناء عندما يحاول المستخدم البحث عن ترجمة أونلاين بدون
/// أن يكون قد أدخل مفتاح API الخاص به فالإعدادات بعد. الشاشة المستدعية
/// (player_subtitle_panel.dart) تلتقطه وتعرض رسالة توجّه المستخدم للإعدادات
/// بدل فشل صامت أو خطأ 401 غير مفهوم.
class MissingApiKeyException implements Exception {}

class OpenSubtitlesService {
  static const String _baseUrl = 'https://api.opensubtitles.com/api/v1';

  /// مفتاح OpenSubtitles الخاص بالمستخدم - يُمرَّر من SettingsProvider، لأن
  /// كل مستخدم خاصو يسجّل حساب مجاني على opensubtitles.com ويجيب مفتاحه
  /// الخاص (الخدمة ما كتسمحش بمفتاح واحد مشترك بين كل المستخدمين).
  final String apiKey;
  final http.Client _client;

  OpenSubtitlesService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<List<SubtitleResult>> search({
    required String query,
    String language = 'ar',
    int limit = 20,
  }) async {
    if (apiKey.trim().isEmpty) throw MissingApiKeyException();

    final uri = Uri.parse('$_baseUrl/subtitles');
    final headers = {
      'Api-Key': apiKey,
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'query': query,
      'languages': language,
      'limit': limit,
    });

    final response = await _client.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => SubtitleResult.fromJson(e)).toList();
    } else {
      throw Exception('فشل البحث: ${response.statusCode}');
    }
  }

  Future<File> download(String downloadUrl, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    final response = await _client.get(Uri.parse(downloadUrl));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('فشل التنزيل: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}