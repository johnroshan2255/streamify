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

  /// Plugin state: Pending, Metadata, Downloading, Ready, Seeding, etc. Shown on loading UI.
  final _pluginState = Observable<String>('');
  String get pluginState => _pluginState.value;

  final _peers = Observable(0);
  int get peers => _peers.value;

  final _downloadSpeed = Observable<int>(0);
  int get downloadSpeed => _downloadSpeed.value;

  final _eta = Observable<int>(-1);
  int get eta => _eta.value;

  TorrentStreamSession? _session;

  /// Start stream. Stops any existing session first (reference pattern).
  Future<void> startStream(String magnetLink) async {
    runInAction(() {
      _status.value = StreamStatus.initializing;
      _errorMessage.value = null;
      _statusMessage.value = 'Starting torrent stream...';
      _pluginState.value = 'Starting...';
      _peers.value = 0;
      _downloadSpeed.value = 0;
      _eta.value = -1;
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
        final stateStr = statusMap['state']?.toString() ?? 'Pending';
        final peersVal = statusMap['peers'] is int ? statusMap['peers'] as int : 0;
        final speedVal = statusMap['downloadSpeed'] is int
            ? statusMap['downloadSpeed'] as int
            : (statusMap['downloadSpeed'] is num
                ? (statusMap['downloadSpeed'] as num).toInt()
                : 0);
        final etaVal = statusMap['eta'] is int
            ? statusMap['eta'] as int
            : (statusMap['eta'] is num ? (statusMap['eta'] as num).toInt() : -1);

        runInAction(() {
          _progress.value = progressVal;
          _pluginState.value = stateStr;
          _peers.value = peersVal;
          _downloadSpeed.value = speedVal;
          _eta.value = etaVal;
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
        _pluginState.value = '';
        _peers.value = 0;
        _downloadSpeed.value = 0;
        _eta.value = -1;
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
