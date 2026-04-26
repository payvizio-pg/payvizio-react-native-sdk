'use strict';

const { NativeModules } = require('react-native');

const Native = NativeModules.PayvizioRN;
if (!Native) {
    throw new Error(
        '@payvizio/react-native: native module not linked. ' +
        'Run `pod install` (iOS) and ensure autolinking is enabled (RN >= 0.60).'
    );
}

/** Final-state status — matches the server enum plus a synthetic CANCELLED for user-close. */
const PaymentStatus = Object.freeze({
    AUTHORIZED:  'AUTHORIZED',
    CAPTURED:    'CAPTURED',
    AUTH_FAILED: 'AUTH_FAILED',
    FAILED:      'FAILED',
    VOIDED:      'VOIDED',
    EXPIRED:     'EXPIRED',
    CANCELLED:   'CANCELLED',
});

class Payvizio {
    /**
     * Configure once per app start. Idempotent — calling again replaces config.
     * @param {{apiBaseUrl: string, checkoutUrl?: string, pollIntervalMs?: number, dismissible?: boolean}} options
     */
    configure(options) {
        if (!options || !options.apiBaseUrl) {
            return Promise.reject(new Error('apiBaseUrl is required'));
        }
        return Native.configure({
            apiBaseUrl:     options.apiBaseUrl,
            checkoutUrl:    options.checkoutUrl || null,
            pollIntervalMs: options.pollIntervalMs ?? 2500,
            dismissible:    options.dismissible !== false,
        });
    }

    /** Best-effort TLS warm-up. */
    prefetch() {
        return Native.prefetch();
    }

    /**
     * Open the hosted checkout for sessionId.
     * @returns {Promise<{sessionId: string, status: string, ...}>} resolves with the terminal result.
     */
    checkout(sessionId) {
        if (!sessionId) return Promise.reject(new Error('sessionId is required'));
        return Native.checkout(sessionId);
    }

    /**
     * Launch a `upi://pay?...` intent on the device's default UPI app. Resolves
     * to true when an app handled the intent, false otherwise.
     */
    launchUpiIntent(intentUrl) {
        if (typeof intentUrl !== 'string' || !intentUrl.startsWith('upi://')) {
            return Promise.reject(new Error('intentUrl must use upi:// scheme'));
        }
        return Native.launchUpiIntent(intentUrl);
    }
}

module.exports = { Payvizio: new Payvizio(), PaymentStatus };
