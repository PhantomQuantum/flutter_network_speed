import Flutter
import UIKit
import SystemConfiguration


public class SwiftFlutterNetworkSpeedPlugin: NSObject, FlutterPlugin {
private var lastRx: UInt64 = 0
private var lastTx: UInt64 = 0
private var lastTime: TimeInterval = Date().timeIntervalSince1970 * 1000.0


public static func register(with registrar: FlutterPluginRegistrar) {
let channel = FlutterMethodChannel(name: "flutter_network_speed", binaryMessenger: registrar.messenger())
let instance = SwiftFlutterNetworkSpeedPlugin()
registrar.addMethodCallDelegate(instance, channel: channel)
}


public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
switch call.method {
case "getNetworkSpeed":
let speed = getNetworkSpeed()
result(["downloadKbps": speed.download, "uploadKbps": speed.upload])
default:
result(FlutterMethodNotImplemented)
}
}


// 返回 (downloadKbps, uploadKbps)
private func getNetworkSpeed() -> (download: Double, upload: Double) {
var addrs: UnsafeMutablePointer<ifaddrs>? = nil
var rx: UInt64 = 0
var tx: UInt64 = 0


if getifaddrs(&addrs) == 0 {
var ptr = addrs
while ptr != nil {
defer { ptr = ptr?.pointee.ifa_next }
guard let interface = ptr?.pointee else { break }
let name = String(cString: interface.ifa_name)


let flags = Int32(interface.ifa_flags)
let addr = interface.ifa_addr.pointee.sa_family
// 只看 AF_LINK 层，包含数据计数
if addr == UInt8(AF_LINK) {
if name.hasPrefix("lo") { continue }
if let data = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>?.self) {
let ibytes = UInt64(data.pointee.ifi_ibytes)
let obytes = UInt64(data.pointee.ifi_obytes)
// 过滤常见接口名
if name.hasPrefix("en") || name.hasPrefix("pdp_ip") || name.hasPrefix("awdl") || name.hasPrefix("utun") {
rx += ibytes
tx += obytes
}
}
}
}
freeifaddrs(addrs)
}


let now = Date().timeIntervalSince1970 * 1000.0
let dt = now - lastTime
let drx = Int64(rx) - Int64(lastRx)
let dtx = Int64(tx) - Int64(lastTx)


lastRx = rx
lastTx = tx
lastTime = now


guard dt > 0 else { return (0.0, 0.0) }


let downloadKbps = (Double(drx) * 1000.0 / dt) / 1024.0
let uploadKbps = (Double(dtx) * 1000.0 / dt) / 1024.0


return (downloadKbps, uploadKbps)
}
}
