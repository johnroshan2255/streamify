import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Netflix-style video player using Chewie with play/pause, seek bar, buffer, fullscreen.
/// Handles app lifecycle (pause/resume) and disposes controllers properly.
class ChewiePlayerWidget extends StatefulWidget {
  const ChewiePlayerWidget({
    super.key,
    required this.streamUrl,
    this.title = 'Streamify',
    this.onPlaying,
  });

  final String streamUrl;
  final String title;
  final VoidCallback? onPlaying;

  @override
  State<ChewiePlayerWidget> createState() => _ChewiePlayerWidgetState();
}

class _ChewiePlayerWidgetState extends State<ChewiePlayerWidget> with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _initializePlayer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_videoController == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _videoController!.pause();
        break;
      case AppLifecycleState.resumed:
        _videoController!.play();
        break;
      default:
        break;
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(widget.streamUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red.shade700,
          handleColor: Colors.red.shade700,
          backgroundColor: Colors.grey.shade600,
          bufferedColor: Colors.grey.shade500,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
        ),
        errorBuilder: (context, message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
        _initialized = true;
      });
      widget.onPlaying?.call();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _disposeVideoController();
    super.dispose();
  }

  void _disposeVideoController() {
    try {
      _videoController?.pause();
    } catch (_) {}
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white70),
              SizedBox(height: 16),
              Text('Preparing playback...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}
