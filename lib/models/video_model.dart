class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      site: json['site']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  bool get isYouTubeTrailer => 
      site.toLowerCase() == 'youtube' && 
      type.toLowerCase() == 'trailer' && 
      key.isNotEmpty;
}
