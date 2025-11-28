//
//  TicTacToeGame.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

final class TicTacToeGame {
  private let ratingURL = URL(string: "https://babin.info/tic-tac-toe")!
  static let shared = TicTacToeGame()
  private let engine = TicTacToeGameEngine()
  
  private var startDate: Date?
  private(set) var wins = 0
  private(set) var fails = 0
  
  private init() {
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
      handleEnd(winner: winner)
      return (true, winner.rawValue, nil)
    }
    engine.switchPlayer()
    // AI move
    if let aiIndex = engine.aiMove() {
      if let winner = engine.checkWinner() {
        handleEnd(winner: winner)
        return (true, winner.rawValue, aiIndex)
      }
      engine.switchPlayer()
      return (true, nil, aiIndex)
    }
    return (true, nil, nil)
  }
  
  func getBoard() -> [TicTacToePlayer] { engine.board }
  
  private func handleEnd(winner: TicTacToePlayer) {
    let duration = Int(Date().timeIntervalSince(startDate ?? Date()))
    switch winner {
    case .User:
      wins += 1
    case .AI:
      fails += 1
      // stop the game sequence
      notifyRequestName(wins: wins, duration: duration)
    case .None:
      break
    }
  }
  
  private func notifyRequestName(wins: Int, duration: Int) {
    TicTacToeModule.shared?.sendEvent(name: "requestName", body: ["wins": wins, "duration": duration])
  }
  
  // Called from JS after JS prompts user for name
  func submitNameAndSend(_ name: String, duration: Int) async {
    let record = GameRecord(name: name, wins: wins, fails: fails, durationSeconds: duration)
    await saveRecordLocal(record)
    
//    let payload: [String: Any] = ["name": name, "wins": wins, "time": duration]
//    var req = URLRequest(url: ratingURL)
//    req.httpMethod = "POST"
//    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    do {
//      req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
//      let (_, response) = try await URLSession.shared.data(for: req)
//      if let http = response as? HTTPURLResponse, http.statusCode >= 200 && http.statusCode < 300 {
//        // success — optionally emit event
//        TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "ok"])
//      } else {
//        TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "error"])
//      }
//    } catch {
//      TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "error", "message": error.localizedDescription])
//    }
  }
  
  func saveRecordLocal(_ record: GameRecord) async {
    do {
      let ctx = try ModelContext(.init(for: GameRecord.self))
      ctx.insert(record)
      TicTacToeModule.shared?.sendEvent(name: "localSave", body: ["ok": true])
    } catch {
      TicTacToeModule.shared?.sendEvent(name: "localSave", body: ["ok": false, "error": error.localizedDescription])
    }
  }
  
  func fetchRating() async -> [[String: Any]] {
//    var req = URLRequest(url: ratingURL)
//    req.httpMethod = "GET"
//    do {
//      let (data, response) = try await URLSession.shared.data(for: req)
//      if let http = response as? HTTPURLResponse, http.statusCode >= 200 && http.statusCode < 300 {
//        if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
//          return json
//        }
//      }
//    } catch {
//      // fall through to local db
//    }
//    // Fallback: read local GameRecord objects and convert to json
    do {
      let ctx = try ModelContext(.init(for: GameRecord.self))
      let req = FetchDescriptor<GameRecord>()
      let results = try ctx.fetch(req)
      return results.map { r in
        ["name": r.name, "wins": r.wins, "fails": r.fails]
      }
    } catch {
      return []
    }
  }
}
