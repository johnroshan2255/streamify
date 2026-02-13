import 'package:equatable/equatable.dart';

/// Domain model for a single torrent/movie from search API.
/// Maps from API response data.torrents[].
class TorrentModel extends Equatable {
  const TorrentModel({
    required this.id,
    required this.title,
    this.year,
    this.quality,
    this.size,
    this.seeders,
    this.leechers,
    this.genres = const [],
    this.coverImageUrl,
    required this.magnetLink,
  });

  final String id;
  final String title;
  final String? year;
  final String? quality;
  final String? size;
  final int? seeders;
  final int? leechers;
  final List<String> genres;
  final String? coverImageUrl;
  final String magnetLink;

  @override
  List<Object?> get props => [id, title, year, quality, size, seeders, leechers, genres, coverImageUrl, magnetLink];

  /// Builds from API map. API uses PascalCase (Name, Magnet, CoverImage, etc.).
  factory TorrentModel.fromJson(Map<String, dynamic> json) {
    final magnetLink = json['Magnet']?.toString() ??
        json['magnet']?.toString() ??
        json['magnet_uri']?.toString() ??
        json['magnetLink']?.toString() ??
        '';
    final id = json['Hash']?.toString() ??
        json['id']?.toString() ??
        json['hash']?.toString() ??
        magnetLink.hashCode.toString();
    final title = json['Name']?.toString() ??
        json['title']?.toString() ??
        json['name']?.toString() ??
        'Unknown';
    final year = json['Year']?.toString() ?? json['year']?.toString();
    final quality = json['Quality']?.toString() ??
        json['quality']?.toString() ??
        json['resolution']?.toString();
    final size = json['Size']?.toString() ?? json['size']?.toString();
    final seeders = _parseInt(json['Seeders'] ?? json['seeders'] ?? json['seeds']);
    final leechers = _parseInt(json['Leechers'] ?? json['leechers'] ?? json['peers']);
    final genres = _parseGenres(json['Genres'] ?? json['genres'] ?? json['genre']);
    final coverImageUrl = json['CoverImage']?.toString() ??
        json['cover_image']?.toString() ??
        json['coverImageUrl']?.toString() ??
        json['poster']?.toString() ??
        json['image']?.toString();

    return TorrentModel(
      id: id,
      title: title,
      year: year,
      quality: quality,
      size: size,
      seeders: seeders,
      leechers: leechers,
      genres: genres,
      coverImageUrl: coverImageUrl,
      magnetLink: magnetLink,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static List<String> _parseGenres(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    if (v is String) return v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return [];
  }
}
