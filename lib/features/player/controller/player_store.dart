import 'dart:io';

import 'package:flutter_go_torrent_streamer/flutter_go_torrent_streamer.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Matches reference: [Rayankrishna/torrent_streamer](https://github.com/Rayankrishna/torrent_streamer).
/// Stop any existing session first, then start; use progress threshold for "ready" (no selectFile).
enum StreamStatus { initial, initializing, buffering, playing, error }

class PlayerStore {
  final _status = Observable(StreamStatus.initial);
  StreamStatus get status => _status.value;

  final _streamUrl = Observable<String?>(null);
  String? get streamUrl => _streamUrl.value;

  final _errorMessage = Observable<String?>(null);
  String? get errorMessage => _errorMessage.value;

  final _statusMessage = Observable<String?>(null);
  String? get statusMessage => _statusMessage.value;

  final _progress = Observable(0.0);
  double get progress => _progress.value;

  TorrentStreamSession? _session;

  /// Start stream. Stops any existing session first (reference pattern).
  Future<void> startStream(String magnetLink) async {
    runInAction(() {
      _status.value = StreamStatus.initializing;
      _errorMessage.value = null;
      _statusMessage.value = 'Starting torrent stream...';
    });

    try {
      if (Platform.isAndroid) {
        final statuses = await [
          Permission.storage,
        ].request();
        if (statuses[Permission.storage] != PermissionStatus.granted) {
          // Proceed but may fail on some paths
        }
      }

      await stopStream();

      final dir = await getApplicationDocumentsDirectory();
      const savePathSuffix = 'streamify_cache';
      final savePath = '${dir.path}/$savePathSuffix';

      runInAction(() => _statusMessage.value = 'Initializing stream session...');

      _session = await FlutterTorrentStreamer().startStream(magnetLink, savePath);

      if (_session == null || _session!.streamUrl.isEmpty) {
        throw Exception('Failed to get stream URL');
      }

      runInAction(() {
        _statusMessage.value = 'Metadata fetched. Buffering...';
        _status.value = StreamStatus.buffering;
      });

      bool ready = false;
      const int maxWaitSeconds = 60;
      for (int i = 0; i < maxWaitSeconds; i++) {
        if (_session == null) return;

        final statusMap = await _session!.getStatus();
        double progressVal = 0;
        if (statusMap['progress'] is num) {
          progressVal = (statusMap['progress'] as num).toDouble();
        }

        print("status: ${statusMap['state']}");
        print("progress: ${statusMap['progress']}");
        print("streamUrl: ${statusMap['url']}");
        print("downloadSpeed: ${statusMap['downloadSpeed']}");
        print("peers: ${statusMap['peers']}");
        print("seeds: ${statusMap['seeds']}");
        print("eta: ${statusMap['eta']}");

        runInAction(() {
          _progress.value = progressVal;
          _statusMessage.value =
              'Buffering... ${(progressVal * 100).toStringAsFixed(1)}%';
        });

        if (progressVal > 0.005) {
          ready = true;
          break;
        }

        await Future<void>.delayed(const Duration(seconds: 1));
      }

      if (!ready && _session != null) {
        runInAction(() =>
            _statusMessage.value = 'Timeout waiting for buffer, attempting playback...');
      }

      if (_session != null) {
        runInAction(() {
          _streamUrl.value = _session!.streamUrl;
          _statusMessage.value = 'Ready to play';
        });
      }
    } catch (e) {
      runInAction(() {
        _status.value = StreamStatus.error;
        _errorMessage.value = e.toString();
        _statusMessage.value = 'Error: $e';
      });
    }
  }

  Future<void> stopStream() async {
    try {
      if (_session != null) {
        await _session!.stop();
      }
      _session = null;
      runInAction(() {
        _streamUrl.value = null;
        _status.value = StreamStatus.initial;
        _statusMessage.value = null;
        _progress.value = 0;
      });
    } catch (_) {}
  }

  void setPlaying() {
    runInAction(() {
      _status.value = StreamStatus.playing;
      _statusMessage.value = 'Playing';
    });
  }
}
