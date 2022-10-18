package sh.cider.android

import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat
import com.apple.android.music.playback.controller.MediaPlayerController
import com.apple.android.music.playback.controller.MediaPlayerControllerFactory
import com.apple.android.music.playback.model.MediaItemType
import com.apple.android.music.playback.model.PlaybackState
import com.apple.android.music.playback.queue.CatalogPlaybackQueueItemProvider
import com.apple.android.sdk.authentication.AuthenticationFactory
import com.apple.android.sdk.authentication.AuthenticationManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val REQUESTCODE_APPLEMUSIC_AUTH = 3456
    private val CHANNEL = "sh.cider.android/musickit"

    private lateinit var methChannel: MethodChannel
    private lateinit var _authResult: MethodChannel.Result

    private lateinit var _authMgr: AuthenticationManager
    private lateinit var _playbackService: MediaPlaybackService
    private lateinit var _player: MediaPlayerController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        _authMgr = AuthenticationFactory.createAuthenticationManager(context)

        // uh ok apple?
        System.loadLibrary("c++_shared")
        System.loadLibrary("appleMusicSDK")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methChannel.setMethodCallHandler { call, result -> callHandler(call, result) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUESTCODE_APPLEMUSIC_AUTH) return super.onActivityResult(
            requestCode,
            resultCode,
            data
        )

        var token = _authMgr.handleTokenResult(data)
        if (token.isError) _authResult.error(
            "MKAUTHFAIL",
            "User Auth Failure",
            token.error.toString()
        )
        else _authResult.success(token.musicUserToken)
    }

    private fun callHandler(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "auth" -> { // User Authentication Sequence
                var devToken = call.argument<String>("devToken")

                var authIntBuilder = _authMgr.createIntentBuilder(devToken)
                var intent = authIntBuilder
                    .setHideStartScreen(false)
                    .setStartScreenMessage("To use this App, please allow us to connect to your Apple Music account.")
                    .build()

                _authResult = result
                startActivityForResult(intent, REQUESTCODE_APPLEMUSIC_AUTH)
            }
            "initPlayer" -> { // Initialize MusicKit
                // Will except if called improperly, so don't!!
                var devToken = call.argument<String>("devToken")!!
                var usrToken = call.argument<String>("usrToken")!!

                _player = MediaPlayerControllerFactory.createLocalController(
                    context, MusicKitToken(devToken, usrToken)
                )

                println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")

                // just some test code
                // TODO: Apparently I need to do some Class Gymnastics to get this to actually play audio
                var builder = CatalogPlaybackQueueItemProvider.Builder();
                //builder.containers(MediaContainerType.ALBUM, "1439331939");
                builder.items(MediaItemType.SONG, "1439331939")
                builder.startItemIndex(0)
                _player.prepare(builder.build(), true);
                _player.play();

                // FIXME: Nothing. Just Silence.

                result.success(null)
            }
            "destroyPlayer" -> { // Destroy MusicKit
                _player.release()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

}
