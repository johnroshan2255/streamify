/// Centralized API configuration and constants.
/// All endpoints and auth are defined here for easy maintenance.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://movie-stream-orpin.vercel.app';
  static const String searchPath = '/api/torrents/search';

  /// Bearer token for authorized API requests.
  /// In production, consider using flutter_secure_storage or env variables.
  static const String authToken =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzcwOTcyOTMwLCJleHAiOjE3NzE1Nzc3MzB9.e5RVyo8sWoXKJFgcUsgRv7UPLYRSwdphS0pwF_qtATM';

  static String searchUrl(String query) =>
      '$baseUrl$searchPath?q=${Uri.encodeQueryComponent(query)}&type=yts';
}
