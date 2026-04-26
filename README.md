# Payvizio React Native SDK

Wraps the native [Android](../android-sdk/) and [iOS](../ios-sdk/) SDKs.
Card capture happens inside the acquirer's iframe nested in our hosted
checkout — integrating apps stay **PCI-out-of-scope**.

- React Native ≥ 0.72
- Autolinking (RN ≥ 0.60)

## Install

```bash
npm install @payvizio/react-native
cd ios && pod install
```

Android: register the package via autolinking (no extra steps on RN ≥ 0.60).
For older versions add `PayvizioPackage()` to `MainApplication`.

## Usage

```js
import { Payvizio, PaymentStatus } from '@payvizio/react-native';

// Configure once during app startup
useEffect(() => {
    Payvizio.configure({ apiBaseUrl: 'https://api.payvizio.com' });
    Payvizio.prefetch();
}, []);

async function pay(sessionId) {
    const result = await Payvizio.checkout(sessionId);
    switch (result.status) {
        case PaymentStatus.CAPTURED:
        case PaymentStatus.AUTHORIZED:
            // success
            break;
        case PaymentStatus.CANCELLED:
            // user dismissed
            break;
        default:
            // failure / expired / voided
    }
}

// Native UPI Intent — server returns the URL via /api/payments/{id}/upi/intent
const launched = await Payvizio.launchUpiIntent('upi://pay?pa=acme@hdfcbank&am=100');
```

## TypeScript

Type definitions ship in [`src/index.d.ts`](./src/index.d.ts).

## What's not included

- Native card form (acquirer's drop-in handles card capture)
- 3DS challenge UI (acquirer hosts the ACS page)
- Saved-card management — render via your own UI before opening checkout

Pre-1.0; pin a specific version in production.
