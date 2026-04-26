#import <React/RCTBridgeModule.h>

// Old-architecture (no codegen) Objective-C shim that exposes the Swift
// methods of PayvizioModule to the React Native bridge. New-architecture
// (TurboModules) consumers should switch to a generated spec — this file is
// the broadly-compatible default.
@interface RCT_EXTERN_MODULE(PayvizioRN, NSObject)

RCT_EXTERN_METHOD(configure:(NSDictionary *)options
                   resolver:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(prefetch:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(checkout:(NSString *)sessionId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(launchUpiIntent:(NSString *)url
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject)

@end
