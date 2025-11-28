//
//  TicTacToeGameEngine.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//

import Foundation
import SwiftData

enum TicTacToePlayer: Int {
  case None = 0
  case User = 1
  case AI = 2
}

final class TicTacToeGameEngine {
  private(set) var board: [TicTacToePlayer] = Array(repeating: .None, count: 9)
  private(set) var currentPlayer: TicTacToePlayer = .User
  
  func reset() {
    board = Array(repeating: .None, count: 9)
    currentPlayer = .User
  }
  
  func makeMove(at index: Int) -> Bool {
    guard index >= 0 && index < 9 else { return false }
    guard board[index] == .None else { return false }
    board[index] = currentPlayer
    return true
  }
  
  func switchPlayer() {
    currentPlayer = (currentPlayer == .User) ? .AI : .User
  }
  
  func checkWinner() -> TicTacToePlayer? {
    let winCombinations = [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6]
    ]
    for win in winCombinations {
      let a = board[win[0]]
      if a != .None && a == board[win[1]] && a == board[win[2]] {
        return a
      }
    }
    if !board.contains(.None) { // it's a draw
      return .None
    }
    return nil
  }
  
  func aiMove() -> Int? {
    // Naive AI: pick random empty cell
    let empties = board.enumerated().filter { $0.element == .None }.map { $0.offset }
    guard !empties.isEmpty else { return nil }
    let pick = empties.randomElement()!
    board[pick] = .AI
    return pick
  }
}
