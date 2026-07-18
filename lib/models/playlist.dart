class Playlist {
  final String id;
  String name;
  List<String> videoPaths;

  Playlist({
    required this.id,
    required this.name,
    List<String>? videoPaths,
  }) : videoPaths = videoPaths ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'videoPaths': videoPaths,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        videoPaths: List<String>.from(json['videoPaths'] as List? ?? []),
      );
}
