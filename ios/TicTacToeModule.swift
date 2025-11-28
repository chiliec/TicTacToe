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
    return ["submitResult"]
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
    let boardValues = TicTacToeGame.shared.getBoard().map { $0.rawValue }
    resolve(boardValues)
  }
  
  @objc func playerMove(_ index: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let res = TicTacToeGame.shared.playerMove(index: index.intValue)
    var dict: [String: Any] = ["ok": res.ok]
    if let winner = res.winner { dict["winner"] = winner }
    if let aiIndex = res.aiIndex { dict["aiIndex"] = aiIndex }
    resolve(dict)
  }
  
  @objc func getStats(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let stats = TicTacToeGame.shared.getUserStats()
    resolve(stats)
  }
  
  @objc func getCurrentUserName(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(TicTacToeGame.shared.currentUserName)
  }
  
  @objc func setUserName(_ name: NSString) {
      TicTacToeGame.shared.setUserName(name as String)
  }
  
  @objc func submitGame(_ duration: NSNumber, winner: NSNumber) {
    Task {
      guard let winnerPlayer = TicTacToePlayer(rawValue: winner.intValue) else {
        return
      }
      await TicTacToeGame.shared.submitGame(duration: duration.intValue, winner: winnerPlayer)
    }
  }
  
  @objc func fetchRating(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task {
      let data = await TicTacToeGame.shared.fetchRating()
      resolve(data)
    }
  }
  
  @objc override func constantsToExport() -> [AnyHashable : Any]! {
    return [:]
  }
}
