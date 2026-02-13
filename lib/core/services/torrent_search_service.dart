import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';

/// Service layer for torrent search API using Dio.
class TorrentSearchService {
  TorrentSearchService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> search(String query) async {
    final response = await _dio.get(
      ApiConstants.searchPath,
      queryParameters: {'q': query, 'type': 'yts'},
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data == null) return {};
      if (data is Map<String, dynamic>) return data;
      return {};
    }

    throw ApiException(
      statusCode: response.statusCode,
      body: response.data?.toString() ?? response.statusMessage ?? '',
    );
  }
}
