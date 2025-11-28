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
  private var startDate: Date?
  
  private(set) var wins = 0
  private(set) var fails = 0
  
  private init() {
    loadStatsFromStore()
  }
  
  func startGame() {
    engine.reset()
    startDate = Date()
  }
  
  func playerMove(index: Int) -> (ok: Bool, winner: Int?, aiIndex: Int?) {
    guard engine.makeMove(at: index) else { return (false, nil, nil) }
    if let winner = engine.checkWinner() {
      handleEnd(winner: winner)
      return (true, winner, nil)
    }
    engine.switchPlayer()
    // AI move
    if let aiIndex = engine.aiMove() {
      if let winner = engine.checkWinner() {
        handleEnd(winner: winner)
        return (true, winner, aiIndex)
      }
      engine.switchPlayer()
      return (true, nil, aiIndex)
    }
    return (true, nil, nil)
  }
  
  func getBoard() -> [Int] { engine.board }
  
  private func handleEnd(winner: Int) {
    let duration = Int(Date().timeIntervalSince(startDate ?? Date()))
    if winner == 1 { // player
      wins += 1
      saveStatsToStore()
    } else if winner == 2 { // ai
      fails += 1
      saveStatsToStore()
      // emit that we need a name to send -> the Swift bridge will emit event
      notifyRequestName(wins: wins, duration: duration)
    } else if winner == 0 {
      // draw: keep playing, no counters changed
    }
  }
  
  private func notifyRequestName(wins: Int, duration: Int) {
    TicTacToeModule.shared?.sendEvent(name: "requestName", body: ["wins": wins, "duration": duration])
  }
  
  private func saveStatsToStore() {
    // We save overall counters into a tiny local key-file; additionally keep historic records when loss+name posted
    // For brevity, store counters in UserDefaults and GameRecord for named submissions
    UserDefaults.standard.set(wins, forKey: "tictactoe_wins")
    UserDefaults.standard.set(fails, forKey: "tictactoe_fails")
  }
  
  private func loadStatsFromStore() {
    wins = UserDefaults.standard.integer(forKey: "tictactoe_wins")
    fails = UserDefaults.standard.integer(forKey: "tictactoe_fails")
  }
  
  // Called from JS after JS prompts user for name
  func submitNameAndSend(_ name: String, duration: Int) async {
    // Save a local record
    let record = GameRecord(name: name, wins: wins, fails: fails, durationSeconds: duration)
    await saveRecord(record)
    
    // POST to server
    let payload: [String: Any] = ["name": name, "wins": wins, "time": duration]
    guard let url = URL(string: "https://babin.info/tic-tac-toe") else { return }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
      req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
      let (_, response) = try await URLSession.shared.data(for: req)
      if let http = response as? HTTPURLResponse, http.statusCode >= 200 && http.statusCode < 300 {
        // success — optionally emit event
        TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "ok"])
      } else {
        TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "error"])
      }
    } catch {
      TicTacToeModule.shared?.sendEvent(name: "submitResult", body: ["status": "error", "message": error.localizedDescription])
    }
  }
  
  func saveRecord(_ record: GameRecord) async {
    do {
      let ctx = try ModelContext(.init(for: GameRecord.self))
      ctx.insert(record)
      TicTacToeModule.shared?.sendEvent(name: "localSave", body: ["ok": true])
    } catch {
      TicTacToeModule.shared?.sendEvent(name: "localSave", body: ["ok": false, "error": error.localizedDescription])
    }
  }
  
  // GET rating from server, fallback to local DB
  func fetchRating() async -> [[String: Any]] {
    if let url = URL(string: "https://babin.info/tic-tac-toe") {
      var req = URLRequest(url: url)
      req.httpMethod = "GET"
      do {
        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode >= 200 && http.statusCode < 300 {
          if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return json
          }
        }
      } catch {
        // fall through to local
      }
    }
    // Fallback: read local GameRecord objects and convert
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
