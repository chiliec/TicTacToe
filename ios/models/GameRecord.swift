//
//  GameRecord.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

@Model
final class GameRecord: Codable {
  var id: UUID
  var name: String
  var durationSeconds: Int
  var winner: Int
  var date: Date
  
  var winnerPlayer: TicTacToePlayer {
    get { TicTacToePlayer(rawValue: winner) ?? .None }
    set { winner = newValue.rawValue }
  }
  
  init(id: UUID = UUID(), name: String, durationSeconds: Int, winner: TicTacToePlayer, date: Date = Date()) {
    self.id = id
    self.name = name
    self.durationSeconds = durationSeconds
    self.winner = winner.rawValue
    self.date = date
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case durationSeconds
    case winner
    case date
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
    self.winner = try container.decode(Int.self, forKey: .winner)
    self.date = try container.decode(Date.self, forKey: .date)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(durationSeconds, forKey: .durationSeconds)
    try container.encode(winner, forKey: .winner)
    try container.encode(date, forKey: .date)
  }
}
