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
  @Attribute(.unique) var id: UUID
  var name: String
  var durationSeconds: Int
  var winner: Int
  var date: Date
  
  var winnerPlayer: TicTacToePlayer {
    get { TicTacToePlayer(rawValue: winner) ?? .None }
    set { winner = newValue.rawValue }
  }
  
  init(
    id: UUID = UUID(),
    name: String,
    durationSeconds: Int,
    winner: TicTacToePlayer,
    date: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.durationSeconds = durationSeconds
    self.winner = winner.rawValue
    self.date = date
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, durationSeconds, winner, date
  }
  
  required init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try c.decode(UUID.self, forKey: .id)
    self.name = try c.decode(String.self, forKey: .name)
    self.durationSeconds = try c.decode(Int.self, forKey: .durationSeconds)
    self.winner = try c.decode(Int.self, forKey: .winner)
    self.date = try c.decode(Date.self, forKey: .date)
  }
  
  func encode(to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: CodingKeys.self)
    try c.encode(id, forKey: .id)
    try c.encode(name, forKey: .name)
    try c.encode(durationSeconds, forKey: .durationSeconds)
    try c.encode(winner, forKey: .winner)
    try c.encode(date, forKey: .date)
  }
}
