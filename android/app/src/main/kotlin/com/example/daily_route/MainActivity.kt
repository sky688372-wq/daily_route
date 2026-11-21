package com.example.daily_route

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 지도 SDK를 불러오기 전에 ABI를 확인해 x86 기기의 네이티브 충돌 방지
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daily_route/device_info")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPrimaryAbi" -> result.success(Build.SUPPORTED_ABIS.firstOrNull())
                    else -> result.notImplemented()
                }
            }
    }
}
