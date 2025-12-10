# flutter_network_speed


A Flutter plugin to fetch approximate real-time network speed (download/upload) on Android & iOS.

## Example

![Network Speed Example](https://raw.githubusercontent.com/PhantomQuantum/flutter_network_speed/master/assets/demo.jpg)



## Usage
1. Add dependency to `pubspec.yaml`
2. Instantiate `NetworkSpeed()` and call `start()`, then listen to `stream`.


```dart
final ns = NetworkSpeed();
ns.start();
ns.stream.listen((r) => print(r));