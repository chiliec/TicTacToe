//
//  TicTacToeModule.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import React

@objc(TicTacToeModule)
final class TicTacToeModule: RCTEventEmitter {
  
  static weak var shared: TicTacToeModule?
  private let ticTacToeGame: TicTacToeGame
  
  override init() {
    self.ticTacToeGame = TicTacToeGame()
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
    DispatchQueue.main.async { [weak self] in
      self?.ticTacToeGame.startGame()
    }
  }
  
  @objc func getBoard(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async { [weak self] in
      let boardValues = self?.ticTacToeGame.getBoard().map { $0.rawValue }
      resolve(boardValues)
    }
  }
  
  @objc func playerMove(_ index: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { [weak self] in
      guard let res = self?.ticTacToeGame.playerMove(index: index.intValue) else {
        reject("player_move_failed", "playerMove could not be completed", nil)
        return
      }
      var dict: [String: Any] = ["ok": res.ok]
      if let winner = res.winner { dict["winner"] = winner }
      if let aiIndex = res.aiIndex { dict["aiIndex"] = aiIndex }
      resolve(dict)
    }
  }
  
  @objc func getStats(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { [weak self] in
      let stats = self?.ticTacToeGame.getUserStats()
      resolve(stats)
    }
  }
  
  @objc func getCurrentUserName(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(ticTacToeGame.currentUserName)
  }
  
  @objc func setUserName(_ name: NSString) {
    ticTacToeGame.setUserName(name as String)
  }
  
  @objc func submitGame(_ duration: NSNumber, winner: NSNumber) {
    Task { [weak self] in
      guard let winnerPlayer = TicTacToePlayer(rawValue: winner.intValue) else {
        return
      }
      await self?.ticTacToeGame.submitGame(duration: duration.intValue, winner: winnerPlayer)
    }
  }
  
  @objc func fetchRating(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { [weak self] in
      let data = await self?.ticTacToeGame.fetchRating()
      resolve(data)
    }
  }
  
  @objc override func constantsToExport() -> [AnyHashable : Any]! {
    return [:]
  }
}
