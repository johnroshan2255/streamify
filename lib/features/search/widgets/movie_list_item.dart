import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dio_network_image.dart';
import '../models/torrent_model.dart';

/// Poster card for grid: cover image + title below (Cineby-style).
/// Uses DioNetworkImage (Dio + Image.memory) so images load in release on device.
class MovieListItem extends StatelessWidget {
  const MovieListItem({
    super.key,
    required this.torrent,
    required this.onTap,
  });

  final TorrentModel torrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildCover(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              torrent.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final url = torrent.coverImageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: AppTheme.surface,
        child: const Icon(Icons.movie_outlined, size: 48, color: AppTheme.textSecondary),
      );
    }
    return Container(
      color: AppTheme.surface,
      child: DioNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: const Center(
          child: CircularProgressIndicator(color: AppTheme.accentRed),
        ),
        errorWidget: const Icon(Icons.broken_image_outlined, size: 48, color: AppTheme.textSecondary),
      ),
    );
  }
}
