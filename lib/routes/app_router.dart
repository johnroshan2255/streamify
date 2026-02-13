import 'package:flutter/material.dart';

import '../features/player/views/player_page.dart';
import '../features/search/models/torrent_model.dart';
import '../features/search/views/search_page.dart';

class AppRouter {
  AppRouter._();

  static const String search = '/';
  static const String player = '/player';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case search:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SearchPage(),
        );
      case player:
        final torrent = settings.arguments as TorrentModel?;
        if (torrent == null) {
          return MaterialPageRoute<void>(
            builder: (_) => const SearchPage(),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PlayerPage(torrent: torrent),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const SearchPage(),
        );
    }
  }
}
