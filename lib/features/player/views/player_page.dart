import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/theme/app_theme.dart';
import '../../search/models/torrent_model.dart';
import '../controller/player_store.dart';
import '../widgets/chewie_player_widget.dart';

/// Matches reference: [Rayankrishna/torrent_streamer](https://github.com/Rayankrishna/torrent_streamer).
/// initState: startStream(magnet); dispose: stopStream then dispose controllers.
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.torrent});

  final TorrentModel torrent;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final PlayerStore _store = PlayerStore();

  @override
  void initState() {
    super.initState();
    _store.startStream(widget.torrent.magnetLink);
  }

  @override
  void dispose() {
    _store.stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.torrent.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            if (_store.streamUrl != null && _store.streamUrl!.isNotEmpty) {
              return ChewiePlayerWidget(
                streamUrl: _store.streamUrl!,
                title: widget.torrent.title,
                onPlaying: () => _store.setPlaying(),
              );
            }

            if (_store.status == StreamStatus.error) {
              return _buildError(_store.errorMessage ?? 'Unknown error');
            }

            if (_store.status == StreamStatus.initializing ||
                _store.status == StreamStatus.buffering) {
              return _buildBuffering(
                _store.statusMessage ?? 'Initializing...',
                _store.progress,
              );
            }

            return _buildBuffering(
              _store.statusMessage ?? 'Loading...',
              _store.progress,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBuffering(String message, double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.accentRed),
          const SizedBox(height: 20),
          Text(
            progress > 0
                ? '$message ${(progress * 100).toStringAsFixed(0)}%'
                : message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
