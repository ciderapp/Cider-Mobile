package sh.cider.android

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.apple.android.sdk.authentication.*;

class MainActivity: FlutterActivity() {
    private val REQUESTCODE_APPLEMUSIC_AUTH = 3456;
    private val CHANNEL = "sh.cider.android/musickit";

    private lateinit var authChannel: MethodChannel
    private lateinit var _result: MethodChannel.Result

    private lateinit var _authMgr: AuthenticationManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        _authMgr = AuthenticationFactory.createAuthenticationManager(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        authChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        authChannel.setMethodCallHandler { call, result ->
            if(call.method == "auth")
            {
                var devToken = call.argument<String>("devToken")

                var authIntBuilder = _authMgr.createIntentBuilder(devToken);
                var intent = authIntBuilder
                    .setHideStartScreen(false)
                    .setStartScreenMessage("To use this App, please allow us to connect to your Apple Music account.")
                    .build();

                _result = result
                startActivityForResult(intent, REQUESTCODE_APPLEMUSIC_AUTH);
            }
            else
                result.notImplemented();
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if(requestCode != REQUESTCODE_APPLEMUSIC_AUTH)
            return super.onActivityResult(requestCode, resultCode, data)
        
        var token = _authMgr.handleTokenResult(data)
        if(token.isError)
            _result.error("MKAUTHFAIL","User Auth Failure", token.error.toString())
        else
            _result.success(token.musicUserToken)
    }

}
