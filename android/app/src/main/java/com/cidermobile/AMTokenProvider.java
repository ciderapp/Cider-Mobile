package com.cidermobile;

import com.apple.android.sdk.authentication.*;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

public class AMTokenProvider extends ReactContextBaseJavaModule implements ActivityEventListener {
    private static final int REQUESTCODE_APPLEMUSIC_AUTH = 3456;
    private static final String TAG = "Cider_AMTokenProvider";

    protected final AuthenticationManager authMgr;
    protected Promise auth_promise;

    AMTokenProvider(ReactApplicationContext context){
        super(context);
        authMgr = AuthenticationFactory.createAuthenticationManager(context);
        context.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "AMTokenProvider";
    }

    @ReactMethod
    public void generateUserToken(String developerToken, Promise promise) {
        AuthIntentBuilder authIntBuilder = authMgr.createIntentBuilder(developerToken);
        Intent intent = authIntBuilder
                .setHideStartScreen(false)
                .setStartScreenMessage("To use this App, please allow us to connect to your Apple Music account.")
                .build();
        startActivityForResult(intent, REQUESTCODE_APPLEMUSIC_AUTH, promise);
        Log.d(TAG, "generateUserToken: Sent request for authentication");
    }

    public void startActivityForResult(Intent intent, int requestCode, Promise promise) {
        Activity activity = getCurrentActivity();
        if(activity == null) {
            Log.d(TAG, "startActivityForResult: Activity is null");
            return;
        }

        activity.startActivityForResult(intent, requestCode);
        auth_promise = promise;
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if(activity != getCurrentActivity())
            return; // Not our problem

        Log.d(TAG, "onActivityResult: requestCode: " + requestCode + ", resultCode: " + resultCode);
        if(requestCode != REQUESTCODE_APPLEMUSIC_AUTH)
            return; // Just don't give a shit about everything else

        TokenResult token = authMgr.handleTokenResult(data);

        if(token.isError()) {
            Log.d(TAG, "onActivityResult: User Authentication Failure. " + token.getError().toString());
            auth_promise.reject("User Auth Failure", token.getError().toString());
            return;
        }

        auth_promise.resolve(token.getMusicUserToken());
    }

    @Override
    public void onNewIntent(Intent intent) {
        // I don't want to play with you anymore
    }
}
