import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Loads an image via Dio (bytes) then displays with [Image.memory].
/// Works in release on device when [Image.network] / [CachedNetworkImage] fail
/// (different HTTP stack, User-Agent, no path_provider cache).
class DioNetworkImage extends StatefulWidget {
  const DioNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    followRedirects: true,
    headers: {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      'Accept': 'image/*,*/*',
    },
  ));

  @override
  State<DioNetworkImage> createState() => _DioNetworkImageState();
}

class _DioNetworkImageState extends State<DioNetworkImage> {
  late Future<List<int>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadImage(widget.imageUrl);
  }

  @override
  void didUpdateWidget(DioNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _future = _loadImage(widget.imageUrl);
    }
  }

  Future<List<int>?> _loadImage(String url) async {
    if (url.isEmpty) return null;
    try {
      final response = await DioNetworkImage._dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator());
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return widget.errorWidget ??
              const Center(child: Icon(Icons.broken_image_outlined, size: 48));
        }
        return Image.memory(
          Uint8List.fromList(bytes),
          fit: widget.fit,
          gaplessPlayback: true,
        );
      },
    );
  }
}
