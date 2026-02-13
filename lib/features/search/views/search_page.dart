import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di/app_stores.dart';
import '../../../core/theme/app_theme.dart';
import '../../player/views/player_page.dart';
import '../controller/search_store.dart';
import '../models/torrent_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/movie_list_item.dart';
import '../widgets/search_bar_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.search(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Streamify',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBarWidget(store: store),
            Observer(builder: (_) => _buildSectionHeader(store)),
            Expanded(child: Observer(builder: (_) => _buildBody(context, store))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(SearchStore store) {
    final count = store.torrents.length;
    final label = store.query.trim().isEmpty ? 'Trending Today' : 'Search results';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count results found',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchStore store) {
    if (store.error != null) {
      return ErrorState(
        message: store.error!,
        onRetry: () {
          store.clearError();
          store.search();
        },
      );
    }

    if (store.isLoading && store.torrents.isEmpty) {
      return const LoadingState();
    }

    if (store.torrents.isEmpty) {
      if (store.query.trim().isEmpty) {
        return _buildInitialPlaceholder();
      }
      return const EmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: store.torrents.length,
      itemBuilder: (context, index) {
        final torrent = store.torrents[index];
        return MovieListItem(
          torrent: torrent,
          onTap: () => _openStreamPage(context, torrent),
        );
      },
    );
  }

  Widget _buildInitialPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for movies',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the search bar above',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openStreamPage(BuildContext context, TorrentModel torrent) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PlayerPage(torrent: torrent),
      ),
    );
  }
}
