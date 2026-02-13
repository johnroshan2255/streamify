import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../models/torrent_model.dart';
import '../repository/torrent_search_repository.dart';

class SearchStore {
  SearchStore(this._repository);

  final TorrentSearchRepository _repository;

  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Timer? _debounceTimer;

  final _query = Observable('');
  String get query => _query.value;

  final _isLoading = Observable(false);
  bool get isLoading => _isLoading.value;

  final _torrents = ObservableList<TorrentModel>.of([]);
  List<TorrentModel> get torrents => _torrents;

  final _error = Observable<String?>(null);
  String? get error => _error.value;

  /// Updates query and schedules a debounced search (search on change).
  void setQuery(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    runInAction(() {
      _query.value = value;
      _error.value = null;
    });

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      runInAction(() {
        _torrents.clear();
        _isLoading.value = false;
      });
      return;
    }

    _debounceTimer = Timer(_searchDebounce, () {
      _debounceTimer = null;
      search();
    });
  }

  Future<void> search() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    final q = _query.value.trim();
    runInAction(() {
      if (q.isEmpty) {
        _torrents.clear();
        _isLoading.value = false;
        _error.value = null;
        return;
      }
      _isLoading.value = true;
      _error.value = null;
    });

    final result = await _repository.search(q);

    runInAction(() {
      _isLoading.value = false;
      result.when(
        success: (list) {
          _torrents.clear();
          _torrents.addAll(list);
          _error.value = null;
        },
        failure: (err, _) {
          _error.value = err is ApiException ? err.body : err.toString();
        },
      );
    });
  }

  void clearError() {
    runInAction(() => _error.value = null);
  }
}
