import 'package:flutter/material.dart';
import 'package:flutter_network_speed/flutter_network_speed.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NetworkSpeed _ns = NetworkSpeed();
  double down = 0, up = 0;

  @override
  void initState() {
    super.initState();
    _ns.stream.listen((r) {
      setState(() {
        down = r.downloadKbps;
        up = r.uploadKbps;
      });
    });
    _ns.start();
  }

  @override
  void dispose() {
    _ns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Network Speed Example')),
        body: Center(
          child: Text(
            '↓ ${down.toStringAsFixed(2)} KB/s\n↑ ${up.toStringAsFixed(2)} KB/s',
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
