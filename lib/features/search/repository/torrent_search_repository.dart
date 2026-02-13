import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../data/torrent_search_data_source.dart';
import '../models/torrent_model.dart';

/// Repository for torrent search: wraps data source and returns Result.
class TorrentSearchRepository {
  TorrentSearchRepository(this._dataSource);

  final TorrentSearchDataSource _dataSource;

  Future<Result<List<TorrentModel>>> search(String query) async {
    if (query.trim().isEmpty) {
      return const Success([]);
    }
    try {
      final list = await _dataSource.search(query.trim());
      return Success(list);
    } on ApiException catch (e, s) {
      return Failure(e, s);
    } on DioException catch (e, s) {
      return Failure(
        ApiException(
          statusCode: e.response?.statusCode,
          body: e.response?.data?.toString() ?? e.message ?? e.toString(),
        ),
        s,
      );
    } catch (e, s) {
      return Failure(e, s);
    }
  }
}
