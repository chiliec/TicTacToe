//
//  TicTacToeModule.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import React

@objc(TicTacToeModule)
class TicTacToeModule: RCTEventEmitter {
  static weak var shared: TicTacToeModule?
  
  override init() {
    super.init()
    TicTacToeModule.shared = self
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  override func supportedEvents() -> [String]! {
    return ["requestName", "submitResult", "localSave"]
  }
  
  func sendEvent(name: String, body: Any?) {
    self.sendEvent(withName: name, body: body)
  }
  
  @objc func startNewGame() {
    DispatchQueue.main.async {
      TicTacToeGame.shared.startGame()
    }
  }
  
  @objc func getBoard(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(TicTacToeGame.shared.getBoard())
  }
  
  @objc func playerMove(_ index: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let res = TicTacToeGame.shared.playerMove(index: index.intValue)
    var dict: [String: Any] = ["ok": res.ok]
    if let winner = res.winner { dict["winner"] = winner }
    if let aiIndex = res.aiIndex { dict["aiIndex"] = aiIndex }
    resolve(dict)
  }
  
  @objc func getStats(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(["wins": TicTacToeGame.shared.wins, "fails": TicTacToeGame.shared.fails])
  }
  
  @objc func submitName(_ name: NSString, duration: NSNumber) {
    Task {
      await TicTacToeGame.shared.submitNameAndSend(name as String, duration: duration.intValue)
    }
  }
  
  @objc func fetchRating(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) async {
    Task {
      let data = await TicTacToeGame.shared.fetchRating()
      resolve(data)
    }
  }
  
  @objc override func constantsToExport() -> [AnyHashable : Any]! {
    return [:]
  }
}
