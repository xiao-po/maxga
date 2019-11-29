package moe.xiaopo.maxga

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import android.R.attr.key
import android.util.Log
import java.nio.charset.Charset
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import android.view.WindowManager


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
        }

    }
}
