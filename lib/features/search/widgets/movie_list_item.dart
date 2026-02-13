import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/torrent_model.dart';

/// Poster card for grid: cover image + title below (Cineby-style).
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
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppTheme.surface,
        child: const Center(child: CircularProgressIndicator(color: AppTheme.accentRed)),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppTheme.surface,
        child: const Icon(Icons.broken_image_outlined, size: 48, color: AppTheme.textSecondary),
      ),
    );
  }
}
