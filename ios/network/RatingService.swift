//
//  RatingNetworking.swift
//  TicTacToe
//
//  Created by Vladimir Babin on 11/28/25.
//
import Foundation

enum RatingError: Error {
  case invalidResponse
  case serverError(Int)
}

struct RatingService {
  
  private static let url = URL(string: "https://babin.info/tic-tac-toe")!
  
  static func receiveRating() async throws -> [GameRecord] {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let http = response as? HTTPURLResponse else {
      throw RatingError.invalidResponse
    }
    guard (200..<300).contains(http.statusCode) else {
      throw RatingError.serverError(http.statusCode)
    }
    
    return try JSONDecoder().decode([GameRecord].self, from: data)
  }
  
  static func submitRating(entry: GameRecord) async {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
      request.httpBody = try JSONEncoder().encode(entry)
      
      let (_, response) = try await URLSession.shared.data(for: request)
      
      if let http = response as? HTTPURLResponse,
         (200..<300).contains(http.statusCode) {
        TicTacToeModule.shared?.sendEvent(
          name: "submitResult",
          body: ["status": "ok"]
        )
      } else {
        TicTacToeModule.shared?.sendEvent(
          name: "submitResult",
          body: ["status": "error"]
        )
      }
    } catch {
      TicTacToeModule.shared?.sendEvent(
        name: "submitResult",
        body: ["status": "error", "message": error.localizedDescription]
      )
    }
  }
}
