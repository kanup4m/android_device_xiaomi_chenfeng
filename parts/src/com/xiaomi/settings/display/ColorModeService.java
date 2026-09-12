/*
 * Copyright (C) 2023-2024 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.display;

import static android.provider.Settings.System.DISPLAY_COLOR_MODE;
import static com.xiaomi.settings.display.DfWrapper.DfParams;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.hardware.display.AmbientDisplayConfiguration;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Log;

import java.util.Map;

public class ColorModeService extends Service {
    private static final String TAG = "XiaomiPartsColorModeService";
    private static final boolean DEBUG = true;

    private static final int DEFAULT_COLOR_MODE = SystemProperties.getInt("persist.sys.sf.native_mode", 0);
    private static final DfParams STANDARD_PARAMS = new DfParams(2, 2, 255);

    /* original/p3/srgb */
    private static final int EXPERT_MODE = 26;
    private static final DfParams EXPERT_PARAMS = new DfParams(EXPERT_MODE, 0, 10);

    /* color mode -> displayfeature (mode, value, cookie) */
    private static final Map<Integer, DfParams> COLOR_MAP = Map.of(
        258, new DfParams(0, 2, 255),  // Vivid
        256, new DfParams(1, 2, 255),  // Saturated
        257, STANDARD_PARAMS,          // Standard
        269, new DfParams(26, 1, 0),   // Original
        268, new DfParams(26, 2, 0),   // P3
        267, new DfParams(26, 3, 0)    // sRGB
    );

    private final Handler mHandler = new Handler(Looper.getMainLooper());
    private AmbientDisplayConfiguration mAmbientConfig;
    private boolean mIsDozing;
    private int mCurrentColorMode = -1;

    private final Runnable mUpdateColorModeRunnable = this::setCurrentColorMode;

    private final ContentObserver mSettingObserver = new ContentObserver(mHandler) {
        @Override
        public void onChange(boolean selfChange) {
            Log.d(TAG, "SettingObserver: onChange");
            mHandler.removeCallbacks(mUpdateColorModeRunnable);
            mHandler.postDelayed(mUpdateColorModeRunnable, 100);
        }
    };

    private final BroadcastReceiver mScreenStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "onReceive: " + intent.getAction());
            handleScreenStateChanged(intent);
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate");
        setupService();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy");
        mHandler.removeCallbacksAndMessages(null);
        teardownService();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void setupService() {
        mAmbientConfig = new AmbientDisplayConfiguration(this);
        getContentResolver().registerContentObserver(Settings.System.getUriFor(DISPLAY_COLOR_MODE),
                false, mSettingObserver, UserHandle.USER_CURRENT);

        IntentFilter screenStateFilter = new IntentFilter();
        screenStateFilter.addAction(Intent.ACTION_SCREEN_ON);
        screenStateFilter.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(mScreenStateReceiver, screenStateFilter);

        setCurrentColorMode();
    }

    private void teardownService() {
        getContentResolver().unregisterContentObserver(mSettingObserver);
        unregisterReceiver(mScreenStateReceiver);
    }

    private void setCurrentColorMode() {
        if (mIsDozing) {
            Log.d(TAG, "Skipping color mode change in AOD");
            return;
        }

        int colorMode = Settings.System.getIntForUser(getContentResolver(), DISPLAY_COLOR_MODE,
                DEFAULT_COLOR_MODE, UserHandle.USER_CURRENT);

        DfParams params = COLOR_MAP.getOrDefault(colorMode, STANDARD_PARAMS);
        Log.i(TAG, "Setting color mode: " + colorMode + ", params=" + params);

        if (params.mode == EXPERT_MODE) {
            if (mCurrentColorMode != colorMode) {
                // Initialize expert mode engine first
                DfWrapper.setDisplayFeature(EXPERT_PARAMS);
                // Set the specific expert submode (Original, P3, or sRGB)
                DfWrapper.setDisplayFeature(params);
            }
        } else {
            // If leaving expert mode, cleanly exit expert mode engine
            if (mCurrentColorMode == 269 || mCurrentColorMode == 268 || mCurrentColorMode == 267) {
                DfWrapper.setDisplayFeature(new DfParams(EXPERT_MODE, 0, 0));
            }
            DfWrapper.setDisplayFeature(params);
        }
        mCurrentColorMode = colorMode;
    }

    private void handleScreenStateChanged(Intent intent) {
        switch (intent.getAction()) {
            case Intent.ACTION_SCREEN_ON:
                handleScreenOn();
                break;
            case Intent.ACTION_SCREEN_OFF:
                handleScreenOff();
                break;
        }
    }

    private void handleScreenOn() {
        if (mIsDozing) {
            mIsDozing = false;
            restoreColorModeAfterDoze();
        }
    }

    private void restoreColorModeAfterDoze() {
        mHandler.removeCallbacks(mUpdateColorModeRunnable);
        mHandler.postDelayed(() -> {
            Log.d(TAG, "Restoring color mode after AOD");
            mCurrentColorMode = -1;
            setCurrentColorMode();
        }, 100);
    }

    private void handleScreenOff() {
        if (!mAmbientConfig.alwaysOnEnabled(UserHandle.USER_CURRENT)) {
            Log.d(TAG, "AOD not enabled");
            mIsDozing = false;
            return;
        }
        mIsDozing = true;
        setStandardColorModeForDoze();
    }

    private void setStandardColorModeForDoze() {
        mHandler.removeCallbacks(mUpdateColorModeRunnable);
        Log.d(TAG, "Setting standard color mode for AOD");
        DfWrapper.setDisplayFeature(STANDARD_PARAMS);
    }
}
