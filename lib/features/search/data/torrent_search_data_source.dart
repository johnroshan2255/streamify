import '../../../../core/services/torrent_search_service.dart';
import '../models/torrent_model.dart';

/// Data source for search: calls service and maps response to domain models.
class TorrentSearchDataSource {
  TorrentSearchDataSource(this._service);

  final TorrentSearchService _service;

  /// Returns list of [TorrentModel] from API data.torrents[].
  /// API returns data with keys: query, page, count, torrents (PascalCase inside each item).
  Future<List<TorrentModel>> search(String query) async {
    final response = await _service.search(query);
    final data = response['data'];
    if (data == null || data is! Map<String, dynamic>) return [];
    final torrents = data['torrents'];
    if (torrents is! List) return [];
    return torrents
        .whereType<Map<String, dynamic>>()
        .map((e) => TorrentModel.fromJson(e))
        .where((m) => m.magnetLink.isNotEmpty)
        .toList();
  }
}
