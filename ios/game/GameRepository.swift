//
//  GameRepository.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/29/25.
//

import SwiftData
import Foundation

final class GameRepository {
  private let modelContainer: ModelContainer
  
  init(modelContainer: ModelContainer = try! ModelContainer(for: GameRecord.self)) {
    self.modelContainer = modelContainer
  }
  
  func save(_ record: GameRecord) throws {
    // TODO: Also call RatingService.submitRating when implemented
    let context = ModelContext(modelContainer)
    context.insert(record)
    try context.save()
  }
  
  func fetchUserStats(name: String) throws -> [String: Any] {
    let context = ModelContext(modelContainer)
    let predicate = #Predicate<GameRecord> { $0.name == name }
    let records = try context.fetch(FetchDescriptor(predicate: predicate))
    
    let wins = records.filter { $0.winnerPlayer == .User }.count
    let losses = records.filter { $0.winnerPlayer == .AI }.count
    let totalDuration = records.reduce(0) { $0 + $1.durationSeconds }
    
    return [
      "wins": wins,
      "losses": losses,
      "totalDuration": totalDuration,
      "games": records.count
    ]
  }
  
  func fetchAllRatings() throws -> [[String: Any]] {
    // TODO: Fetch ratings from RatingService when implemented
    let context = ModelContext(modelContainer)
    let allRecords = try context.fetch(FetchDescriptor<GameRecord>())
    
    var userStats: [String: [GameRecord]] = [:]
    for record in allRecords {
      userStats[record.name, default: []].append(record)
    }
    
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
          maxStreak = max(maxStreak, currentStreak)
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
  }
}
