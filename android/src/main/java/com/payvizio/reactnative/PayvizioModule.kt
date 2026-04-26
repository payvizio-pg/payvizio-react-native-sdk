package com.payvizio.reactnative

import com.facebook.react.bridge.*
import com.payvizio.sdk.PaymentCallback
import com.payvizio.sdk.PaymentResult
import com.payvizio.sdk.Payvizio
import com.payvizio.sdk.PayvizioConfig
import com.payvizio.sdk.UpiIntent

/**
 * React Native bridge to the Payvizio Android SDK. The Activity for the
 * checkout launcher comes from the React context's current Activity — RN
 * keeps that in sync as the host app navigates.
 */
class PayvizioModule(private val ctx: ReactApplicationContext) : ReactContextBaseJavaModule(ctx) {

    override fun getName() = "PayvizioRN"

    @ReactMethod
    fun configure(options: ReadableMap, promise: Promise) {
        val baseUrl = options.getString("apiBaseUrl")
        if (baseUrl.isNullOrBlank()) {
            promise.reject("PVZ_INVALID", "apiBaseUrl is required")
            return
        }
        val checkoutUrl = if (options.hasKey("checkoutUrl") && !options.isNull("checkoutUrl"))
            options.getString("checkoutUrl") else null
        val pollMs = if (options.hasKey("pollIntervalMs") && !options.isNull("pollIntervalMs"))
            options.getInt("pollIntervalMs").toLong() else 2500L
        val dismissible = if (options.hasKey("dismissible") && !options.isNull("dismissible"))
            options.getBoolean("dismissible") else true

        Payvizio.init(PayvizioConfig(
            apiBaseUrl = baseUrl,
            checkoutUrl = checkoutUrl,
            pollIntervalMs = pollMs,
            backButtonDismissible = dismissible))
        promise.resolve(null)
    }

    @ReactMethod
    fun prefetch(promise: Promise) {
        Payvizio.prefetch()
        promise.resolve(null)
    }

    @ReactMethod
    fun checkout(sessionId: String, promise: Promise) {
        val act = currentActivity ?: run {
            promise.reject("PVZ_NO_ACTIVITY", "No foreground Activity"); return
        }
        Payvizio.checkout(act, sessionId, object : PaymentCallback {
            override fun onSuccess(r: PaymentResult) { promise.resolve(toMap(r)) }
            override fun onFailure(r: PaymentResult) { promise.resolve(toMap(r)) }
            override fun onClose() {
                promise.resolve(Arguments.createMap().apply {
                    putString("sessionId", sessionId)
                    putString("status", "CANCELLED")
                })
            }
        })
    }

    @ReactMethod
    fun launchUpiIntent(url: String, promise: Promise) {
        val act = currentActivity ?: run {
            promise.reject("PVZ_NO_ACTIVITY", "No foreground Activity"); return
        }
        promise.resolve(UpiIntent.launch(act, url))
    }

    private fun toMap(r: PaymentResult): WritableMap = Arguments.createMap().apply {
        putString("sessionId", r.sessionId)
        putString("status", r.status.name)
        putString("acquirer", r.acquirer)
        putString("gatewayReference", r.gatewayReference)
        putString("amount", r.amount)
        putString("currency", r.currency)
        putString("failureReason", r.failureReason)
    }
}
