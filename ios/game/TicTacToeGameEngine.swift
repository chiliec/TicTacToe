//
//  TicTacToeGameEngine.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation

enum TicTacToePlayer: Int {
  case None = 0
  case User = 1
  case AI = 2
}

struct AIMode {
  let randomness: Double
  
  let tacticalThinking: Double
  
  static let hard    = AIMode(randomness: 0.00, tacticalThinking: 1.0)
  static let medium  = AIMode(randomness: 0.15, tacticalThinking: 0.8)
  static let easy    = AIMode(randomness: 0.35, tacticalThinking: 0.5)
  static let stupid  = AIMode(randomness: 0.75, tacticalThinking: 0.2)
}

final class TicTacToeGameEngine {
  
  private let wins = [
    [0,1,2],[3,4,5],[6,7,8],
    [0,3,6],[1,4,7],[2,5,8],
    [0,4,8],[2,4,6]
  ]
  
  private(set) var board: [TicTacToePlayer] = Array(repeating: .None, count: 9)
  private(set) var currentPlayer: TicTacToePlayer = .User
  
  let aiMode: AIMode
  
  init(aiMode: AIMode) {
    self.aiMode = aiMode
  }
  
  func reset() {
    board = Array(repeating: .None, count: 9)
    currentPlayer = .User
  }
  
  @discardableResult
  func makeMove(at index: Int) -> Bool {
    guard (0..<9).contains(index), board[index] == .None else {
      return false
    }
    board[index] = currentPlayer
    return true
  }
  
  func switchPlayer() {
    currentPlayer = (currentPlayer == .User) ? .AI : .User
  }
  
  func checkWinner() -> TicTacToePlayer? {
    for win in wins {
      let a = board[win[0]]
      if a != .None && a == board[win[1]] && a == board[win[2]] {
        return a
      }
    }
    return board.contains(.None) ? nil : .None // Draw
  }
}

extension TicTacToeGameEngine {
  
  // MARK: - AI
  
  func aiMove() -> Int? {
    let empties = emptyIndices()
    guard !empties.isEmpty else { return nil }
    
    // AI can decide to make a random move
    if chance(aiMode.randomness) {
      return applyRandomMove(from: empties)
    }
    
    // Try tactical moves (win / block)
    if chance(aiMode.tacticalThinking) {
      if let win = findWinningMove(for: .AI) {
        return apply(win)
      }
      if let block = findWinningMove(for: .User) {
        return apply(block)
      }
    }
    
    // Center
    if board[4] == .None { return apply(4) }
    
    // Corners
    let corners = [0,2,6,8].filter { board[$0] == .None }
    if let c = corners.randomElement() {
      return apply(c)
    }
    
    // Any other
    return applyRandomMove(from: empties)
  }
  
  private func emptyIndices() -> [Int] {
    board.indices.filter { board[$0] == .None }
  }
  
  private func applyRandomMove(from moves: [Int]) -> Int {
    let m = moves.randomElement()!
    board[m] = .AI
    return m
  }
  
  private func apply(_ index: Int) -> Int {
    board[index] = .AI
    return index
  }
  
  private func findWinningMove(for player: TicTacToePlayer) -> Int? {
    for combo in wins {
      let values = combo.map { board[$0] }
      let countPlayer = values.filter { $0 == player }.count
      if countPlayer == 2, let idx = values.firstIndex(of: .None) {
        return combo[idx]
      }
    }
    return nil
  }
  
  private func chance(_ probability: Double) -> Bool {
    Double.random(in: 0...1) < probability
  }
}
