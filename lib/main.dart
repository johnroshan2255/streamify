import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/di/app_stores.dart';
import 'core/network/dio_client.dart';
import 'core/services/torrent_search_service.dart';
import 'core/theme/app_theme.dart';
import 'features/search/controller/search_store.dart';
import 'features/search/data/torrent_search_data_source.dart';
import 'features/search/repository/torrent_search_repository.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final dio = DioClient.instance.dio;
  final searchService = TorrentSearchService(dio);
  final dataSource = TorrentSearchDataSource(searchService);
  final repository = TorrentSearchRepository(dataSource);
  final searchStore = SearchStore(repository);

  runApp(StreamifyApp(searchStore: searchStore));
}

class StreamifyApp extends StatelessWidget {
  const StreamifyApp({super.key, required this.searchStore});

  final SearchStore searchStore;

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      searchStore: searchStore,
      child: MaterialApp(
        title: 'Streamify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        builder: BotToastInit(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.search,
      ),
    );
  }
}
