// lib/flutter_network_speed.dart

/// A simple plugin wrapper for getting real-time network speed.
///
/// Use NetworkSpeed.start() to begin periodic queries (default 1s) and
/// subscribe to [stream] for updates.
library;

import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNetworkSpeed {
  final double downloadKbps;
  final double uploadKbps;

  FlutterNetworkSpeed({required this.downloadKbps, required this.uploadKbps});

  factory FlutterNetworkSpeed.fromMap(Map<dynamic, dynamic> map) {
    return FlutterNetworkSpeed(
      downloadKbps: (map['downloadKbps'] ?? 0).toDouble(),
      uploadKbps: (map['uploadKbps'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() => '↓ ${downloadKbps.toStringAsFixed(2)} KB/s ↑ ${uploadKbps.toStringAsFixed(2)} KB/s';
}

class NetworkSpeed {
  static const MethodChannel _channel = MethodChannel('flutter_network_speed');

  final StreamController<FlutterNetworkSpeed> _controller = StreamController.broadcast();
  Timer? _timer;
  Duration interval;

  NetworkSpeed({this.interval = const Duration(milliseconds: 1000)});

  Stream<FlutterNetworkSpeed> get stream => _controller.stream;

  /// Start periodic polling. If already started, this is a no-op.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) async {
      try {
        final result = await _channel.invokeMethod('getNetworkSpeed');
        if (result is Map) {
          _controller.add(FlutterNetworkSpeed.fromMap(result));
        }
      } catch (e) {
        // ignore error; optionally add an error to the stream
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
