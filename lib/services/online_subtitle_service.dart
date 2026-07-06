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
      downloadUrl: attrs['files']?.first['file_url'] ?? '',
      rating: (attrs['ratings']?.toDouble() ?? 0.0),
      downloadCount: attrs['download_count'] ?? 0,
    );
  }
}

class OpenSubtitlesService {
  static const String _baseUrl = 'https://api.opensubtitles.com/api/v1';
  static const String _apiKey = 'YOUR_API_KEY'; // استبدلها بمفتاحك

  final http.Client _client;

  OpenSubtitlesService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<SubtitleResult>> search({
    required String query,
    String language = 'ar',
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/subtitles');
    final headers = {
      'Api-Key': _apiKey,
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