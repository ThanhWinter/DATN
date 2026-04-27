package com.example.customer

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.listeners.PayOrderListener

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.customer/zalopay"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Init ZaloPay off main thread — sandbox SDK makes a network call on init
        // which can block the main thread 5-10s and trigger MIUI ANR (signal 3).
        Thread { ZaloPaySDK.init(553, Environment.SANDBOX) }.start()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "payOrder") {
                val token = call.argument<String>("zptoken")
                if (token != null) {
                    ZaloPaySDK.getInstance().payOrder(this@MainActivity, token, "zpdk-553://", object : PayOrderListener {
                        override fun onPaymentSucceeded(transactionId: String, transToken: String, appTransID: String) {
                            result.success("SUCCESS")
                        }

                        override fun onPaymentCanceled(transactionId: String, transToken: String) {
                            result.success("CANCELED")
                        }

                        override fun onPaymentError(zaloPayError: ZaloPayError, transactionId: String, transToken: String) {
                            result.success("ERROR")
                        }
                    })
                } else {
                    result.error("INVALID_PARAMS", "Token is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Nhận kết quả khi ZaloPay app quay lại ứng dụng
        ZaloPaySDK.getInstance().onResult(intent)
    }
}
