import 'package:mobx/mobx.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../models/torrent_model.dart';
import '../repository/torrent_search_repository.dart';

class SearchStore {
  SearchStore(this._repository);

  final TorrentSearchRepository _repository;

  final _query = Observable('');
  String get query => _query.value;

  final _isLoading = Observable(false);
  bool get isLoading => _isLoading.value;

  final _torrents = ObservableList<TorrentModel>.of([]);
  List<TorrentModel> get torrents => _torrents;

  final _error = Observable<String?>(null);
  String? get error => _error.value;

  void setQuery(String value) {
    runInAction(() {
      _query.value = value;
      _error.value = null;
    });
  }

  Future<void> search() async {
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
