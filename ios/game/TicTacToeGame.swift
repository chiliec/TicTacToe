//
//  TicTacToeGame.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

final class TicTacToeGame {
  static let shared = TicTacToeGame()
  private let engine = TicTacToeGameEngine()
  
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
  
  private init() {
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
      let ctx = try ModelContext(.init(for: GameRecord.self))
      let req = FetchDescriptor<GameRecord>(predicate: #Predicate { $0.name == currentUserName })
      let records = try ctx.fetch(req)
      
      let wins = records.filter { $0.winnerPlayer == .User }.count
      let losses = records.filter { $0.winnerPlayer == .AI }.count
      let totalDuration = records.reduce(0) { $0 + $1.durationSeconds }
      
      return [
        "wins": wins,
        "losses": losses,
        "totalDuration": totalDuration,
        "games": records.count
      ]
    } catch {
      return ["wins": 0, "losses": 0, "totalDuration": 0, "games": 0]
    }
  }
  
  func submitGame(duration: Int, winner: TicTacToePlayer) async {
    // TODO: RatingService.submitRating when implemented
    let record = GameRecord(name: currentUserName, durationSeconds: duration, winner: winner)
    do {
      let ctx = try ModelContext(.init(for: GameRecord.self))
      ctx.insert(record)
      try ctx.save()
      TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "ok"])
    } catch {
      TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "error", "message": error.localizedDescription])
    }
  }
  
  func fetchRating() async -> [[String: Any]] {
    // TODO: Fetch ratings from RatingService
    do {
      let ctx = try ModelContext(.init(for: GameRecord.self))
      let req = FetchDescriptor<GameRecord>()
      let allRecords = try ctx.fetch(req)
      
      // Group by name
      var userStats: [String: [GameRecord]] = [:]
      for record in allRecords {
        if userStats[record.name] == nil {
          userStats[record.name] = []
        }
        userStats[record.name]?.append(record)
      }
      
      // Calculate stats per user
      var results: [[String: Any]] = []
      for (name, records) in userStats {
        // Sort by date ascending (oldest -> newest)
        let sortedByDate = records.sorted { $0.date < $1.date }
        
        let wins = records.filter { $0.winnerPlayer == .User }.count
        let losses = records.filter { $0.winnerPlayer == .AI }.count
        let totalDuration = records.reduce(0) { $0 + $1.durationSeconds }
        let ratio = (wins + losses) > 0 ? Double(wins) / Double(wins + losses) : 0.0
        
        // Calculate max consecutive win streak (chronological)
        var currentStreak = 0
        var maxStreak = 0
        for record in sortedByDate {
          if record.winnerPlayer == .User {
            currentStreak += 1
            if currentStreak > maxStreak {
              maxStreak = currentStreak
            }
          } else {
            currentStreak = 0
          }
        }
        
        results.append([
          "name": name,
          "wins": wins,
          "losses": losses,
          "ratio": ratio,
          "maxStreak": maxStreak,
          "totalDuration": totalDuration,
          "games": records.count
        ])
      }
      
      return results.sorted { ($0["ratio"] as? Double ?? 0) > ($1["ratio"] as? Double ?? 0) }
    } catch {
      return []
    }
  }
}
