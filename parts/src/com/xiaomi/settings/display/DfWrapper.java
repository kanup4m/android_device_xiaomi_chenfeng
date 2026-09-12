/*
 * Copyright (C) 2023-2024 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.display;

import android.os.IBinder;
import android.os.ServiceManager;
import android.util.Log;
import vendor.xiaomi.hardware.displayfeature_aidl.IDisplayFeature;

public class DfWrapper {

    private static final String TAG = "XiaomiPartsDisplayFeatureWrapper";
    private static final Object sLock = new Object();

    private static IDisplayFeature mDisplayFeature;

    private static final IBinder.DeathRecipient mDeathRecipient = new IBinder.DeathRecipient() {
        @Override
        public void binderDied() {
            Log.w(TAG, "DisplayFeature binder died, clearing cached instance");
            synchronized (sLock) {
                resetDisplayFeatureLocked();
            }
        }
    };

    private static void resetDisplayFeatureLocked() {
        if (mDisplayFeature != null) {
            try {
                mDisplayFeature.asBinder().unlinkToDeath(mDeathRecipient, 0);
            } catch (Exception ignored) {
            }
            mDisplayFeature = null;
        }
    }

    public static IDisplayFeature getDisplayFeature() {
        synchronized (sLock) {
            if (mDisplayFeature != null) {
                IBinder binder = mDisplayFeature.asBinder();
                if (binder != null && binder.isBinderAlive() && binder.pingBinder()) {
                    return mDisplayFeature;
                }
                Log.w(TAG, "Cached DisplayFeature binder is not alive or ping failed, resetting");
                resetDisplayFeatureLocked();
            }

            try {
                String name = "default";
                String fqName = IDisplayFeature.DESCRIPTOR + "/" + name;
                IBinder binder = ServiceManager.getService(fqName);
                if (binder == null) {
                    binder = ServiceManager.waitForDeclaredService(fqName);
                }
                if (binder != null) {
                    binder = android.os.Binder.allowBlocking(binder);
                    mDisplayFeature = IDisplayFeature.Stub.asInterface(binder);
                    binder.linkToDeath(mDeathRecipient, 0);
                    Log.d(TAG, "Connected to DisplayFeature AIDL service");
                } else {
                    Log.e(TAG, "DisplayFeature service binder is null for " + fqName);
                }
            } catch (Exception e) {
                Log.e(TAG, "getDisplayFeature failed!", e);
                resetDisplayFeatureLocked();
            }
            return mDisplayFeature;
        }
    }

    public static void setDisplayFeature(DfParams params) {
        if (params == null) {
            return;
        }
        synchronized (sLock) {
            IDisplayFeature displayFeature = getDisplayFeature();
            if (displayFeature == null) {
                Log.e(TAG, "setDisplayFeature: displayFeature is null, cannot apply " + params);
                return;
            }
            Log.d(TAG, "setDisplayFeature: " + params);
            try {
                displayFeature.setFeature(0, params.mode, params.value, params.cookie);
            } catch (Exception e) {
                Log.e(TAG, "setDisplayFeature failed on first attempt for " + params + ", retrying...", e);
                resetDisplayFeatureLocked();
                displayFeature = getDisplayFeature();
                if (displayFeature != null) {
                    try {
                        displayFeature.setFeature(0, params.mode, params.value, params.cookie);
                        Log.d(TAG, "setDisplayFeature retry succeeded: " + params);
                    } catch (Exception retryEx) {
                        Log.e(TAG, "setDisplayFeature retry failed for " + params, retryEx);
                        resetDisplayFeatureLocked();
                    }
                }
            }
        }
    }

    public static class DfParams {
        /* displayfeature parameters */
        final int mode, value, cookie;

        public DfParams(int mode, int value, int cookie) {
            this.mode = mode;
            this.value = value;
            this.cookie = cookie;
        }

        public String toString() {
            return "DisplayFeatureParams(" + mode + ", " + value + ", " + cookie + ")";
        }
    }
}
