package moe.xiaopo.maxga

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import android.content.Intent
import android.net.Uri


class MainActivity : FlutterActivity() {

    private val CHANNEL = "android/maxga/utils"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
            if (methodCall.method == "hiddenStatusBar") {
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                result.success(true)
            }
            if (methodCall.method == "showStatusBar") {

                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                result.success(true)
            }
            if (methodCall.method == "shareUrl") {
                if (methodCall.arguments is String) {
                    val url = methodCall.arguments as String;
                    val intent = Intent(Intent.ACTION_SEND)
                    intent.setType("text/plain")
                    intent.putExtra(Intent.EXTRA_TEXT, url)
                    this.sendBroadcast(intent)
                }
                result.success(true)
            }
        }

    }
}
