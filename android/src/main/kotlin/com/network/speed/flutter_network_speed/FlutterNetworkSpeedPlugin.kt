package com.network.speed.flutter_network_speed

import android.net.TrafficStats
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterNetworkSpeedPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    // 上一次统计的流量和时间
    private var lastRxBytes: Long = 0
    private var lastTxBytes: Long = 0
    private var lastTime: Long = 0

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_network_speed")
        channel.setMethodCallHandler(this)

        // 初始化为当前流量，保证第一次调用也有合理值
        lastRxBytes = getSafeRxBytes()
        lastTxBytes = getSafeTxBytes()
        lastTime = System.currentTimeMillis()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getNetworkSpeed" -> {
                val speedMap = getNetworkSpeedMap()
                result.success(speedMap)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * 获取安全的总接收字节数，处理 UNSUPPORTED
     */
    private fun getSafeRxBytes(): Long {
        val rx = TrafficStats.getTotalRxBytes()
        return if (rx == TrafficStats.UNSUPPORTED.toLong()) 0 else rx
    }

    /**
     * 获取安全的总发送字节数，处理 UNSUPPORTED
     */
    private fun getSafeTxBytes(): Long {
        val tx = TrafficStats.getTotalTxBytes()
        return if (tx == TrafficStats.UNSUPPORTED.toLong()) 0 else tx
    }

    /**
     * 计算实时下载/上传速度（KB/s）
     */
    private fun getNetworkSpeedMap(): Map<String, Double> {
        val currentRxBytes = getSafeRxBytes()
        val currentTxBytes = getSafeTxBytes()
        val currentTime = System.currentTimeMillis()

        val timeDiff = currentTime - lastTime
        if (timeDiff <= 0) {
            return mapOf("downloadKbps" to 0.0, "uploadKbps" to 0.0)
        }

        val downloadKbps = (currentRxBytes - lastRxBytes) * 1000.0 / timeDiff / 1024
        val uploadKbps = (currentTxBytes - lastTxBytes) * 1000.0 / timeDiff / 1024

        // 更新 last 值
        lastRxBytes = currentRxBytes
        lastTxBytes = currentTxBytes
        lastTime = currentTime

        return mapOf("downloadKbps" to downloadKbps, "uploadKbps" to uploadKbps)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
