//
//  TicTacToeGame.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

final class TicTacToeGame {
  
  private let engine: TicTacToeGameEngine
  private let repository: GameRepository
  
  private let userNameKey = "currentUserName"
  var currentUserName: String {
    get {
      let value = UserDefaults.standard.string(forKey: userNameKey) ?? "Guest"
      return value.isEmpty ? "Guest" : value
    }
    set {
      let value = newValue.isEmpty ? "Guest" : newValue
      UserDefaults.standard.set(value, forKey: userNameKey)
    }
  }
  
  private var startDate: Date?
  
  init(engine: TicTacToeGameEngine = TicTacToeGameEngine(),
       repository: GameRepository = GameRepository()) {
    self.engine = engine
    self.repository = repository
    if currentUserName.isEmpty {
      currentUserName = "Guest"
    }
  }
  
  func startGame() {
    engine.reset()
    startDate = Date()
  }
  
  func playerMove(index: Int) -> (ok: Bool, winner: Int?, aiIndex: Int?) {
    guard engine.makeMove(at: index) else {
      return (false, nil, nil)
    }
    if let winner = engine.checkWinner() {
      return (true, winner.rawValue, nil)
    }
    engine.switchPlayer()
    if let aiIndex = engine.aiMove() {
      if let winner = engine.checkWinner() {
        return (true, winner.rawValue, aiIndex)
      }
      engine.switchPlayer()
      return (true, nil, aiIndex)
    }
    return (true, nil, nil)
  }
  
  func getBoard() -> [TicTacToePlayer] { engine.board }
  
  func setUserName(_ name: String) {
    currentUserName = name.isEmpty ? "Guest" : name
  }
  
  func getUserStats() -> [String: Any] {
    do {
      return try repository.fetchUserStats(name: currentUserName)
    } catch {
      return ["wins": 0, "losses": 0, "totalDuration": 0, "games": 0]
    }
  }
  
  func submitGame(duration: Int, winner: TicTacToePlayer) async {
    let record = GameRecord(name: currentUserName, durationSeconds: duration, winner: winner)
    do {
      try repository.save(record)
      TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "ok"])
    } catch {
      TicTacToeModule.shared?.sendEvent(
        name: "submitResult",
        body: ["status": "error", "message": error.localizedDescription]
      )
    }
  }
  
  func fetchRating() async -> [[String: Any]] {
    do {
      return try repository.fetchAllRatings()
    } catch {
      return []
    }
  }
}
