import Foundation
import React
import Payvizio
import UIKit

/// React Native bridge for the Payvizio iOS SDK. Resolves the top-most VC at
/// checkout-time so the hosted-checkout sheet has a presenter regardless of
/// the host app's navigation stack.
@objc(PayvizioRN)
public class PayvizioModule: NSObject {

    @objc public static func requiresMainQueueSetup() -> Bool { true }

    @objc(configure:resolver:rejecter:)
    public func configure(_ options: NSDictionary,
                          resolver resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject:  @escaping RCTPromiseRejectBlock) {
        guard let baseUrlString = options["apiBaseUrl"] as? String,
              let baseUrl = URL(string: baseUrlString) else {
            reject("PVZ_INVALID", "apiBaseUrl is required", nil); return
        }
        let checkoutUrl = (options["checkoutUrl"] as? String).flatMap(URL.init(string:))
        let pollMs = (options["pollIntervalMs"] as? Int) ?? 2500
        let dismissible = (options["dismissible"] as? Bool) ?? true

        Payvizio.shared.configure(PayvizioConfig(
            apiBaseUrl: baseUrl,
            checkoutUrl: checkoutUrl,
            pollInterval: TimeInterval(pollMs) / 1000.0,
            dismissible: dismissible))
        resolve(nil)
    }

    @objc public func prefetch(_ resolve: @escaping RCTPromiseResolveBlock,
                                rejecter _: @escaping RCTPromiseRejectBlock) {
        Payvizio.shared.prefetch()
        resolve(nil)
    }

    @objc(checkout:resolver:rejecter:)
    public func checkout(_ sessionId: String,
                         resolver resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject:  @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard !sessionId.isEmpty else {
                reject("PVZ_INVALID", "sessionId is required", nil); return
            }
            guard let presenter = Self.topViewController() else {
                reject("PVZ_NO_VC", "No top view controller", nil); return
            }
            let cb = BridgeCallback(sessionId: sessionId, resolve: resolve)
            _ = Payvizio.shared.checkout(presenting: presenter, sessionId: sessionId, callback: cb)
        }
    }

    @objc(launchUpiIntent:resolver:rejecter:)
    public func launchUpiIntent(_ url: String,
                                 resolver resolve: @escaping RCTPromiseResolveBlock,
                                 rejecter reject:  @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            UpiIntent.launch(url) { ok in resolve(ok) }
        }
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}

/// Single-shot result holder — drains the resolve block on the first terminal
/// callback and ignores subsequent ones, matching the SDK's "exactly one
/// terminal" contract.
private final class BridgeCallback: PaymentCallback {
    let sessionId: String
    var resolve: RCTPromiseResolveBlock?

    init(sessionId: String, resolve: @escaping RCTPromiseResolveBlock) {
        self.sessionId = sessionId
        self.resolve = resolve
    }

    func onSuccess(_ r: PaymentResult) { drain(map(r)) }
    func onFailure(_ r: PaymentResult) { drain(map(r)) }
    func onClose() {
        drain(["sessionId": sessionId, "status": "CANCELLED"])
    }

    private func drain(_ payload: [String: Any]) {
        guard let r = resolve else { return }
        r(payload)
        resolve = nil
    }

    private func map(_ r: PaymentResult) -> [String: Any] {
        return [
            "sessionId":        r.sessionId,
            "status":           r.status.rawValue,
            "acquirer":         r.acquirer ?? NSNull(),
            "gatewayReference": r.gatewayReference ?? NSNull(),
            "amount":           r.amount ?? NSNull(),
            "currency":         r.currency ?? NSNull(),
            "failureReason":    r.failureReason ?? NSNull(),
        ]
    }
}
