//
//  TicTacToeModuleBridge.m
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TicTacToeModule, RCTEventEmitter)

RCT_EXTERN_METHOD(startNewGame)
RCT_EXTERN_METHOD(getBoard: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(playerMove:(nonnull NSNumber*)index resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getStats:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(submitName:(NSString *)name duration:(nonnull NSNumber*)duration)
RCT_EXTERN_METHOD(fetchRating:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
