//
//  GameRecord.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

@Model
final class GameRecord {
  var id: UUID
  var name: String
  var wins: Int
  var fails: Int
  var durationSeconds: Int
  var date: Date
  
  init(id: UUID = UUID(), name: String, wins: Int, fails: Int, durationSeconds: Int, date: Date = Date()) {
    self.id = id
    self.name = name
    self.wins = wins
    self.fails = fails
    self.durationSeconds = durationSeconds
    self.date = date
  }
}
