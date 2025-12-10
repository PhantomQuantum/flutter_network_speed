# flutter_network_speed


A Flutter plugin to fetch approximate real-time network speed (download/upload) on Android & iOS.


## Usage
1. Add dependency to `pubspec.yaml`
2. Instantiate `NetworkSpeed()` and call `start()`, then listen to `stream`.


```dart
final ns = NetworkSpeed();
ns.start();
ns.stream.listen((r) => print(r));