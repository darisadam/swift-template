//
//  HTTPClient.swift
//  CoreNetwork
//

import AppCore
import Foundation

public protocol HTTPClientProtocol: Sendable {
  func get<T: Decodable & Sendable>(_ path: String, as type: T.Type) async throws -> T
}

public actor HTTPClient: HTTPClientProtocol {
  private let baseURL: URL
  private let session: URLSession
  private let decoder: JSONDecoder

  public init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.decoder = decoder
  }

  public func get<T: Decodable & Sendable>(_ path: String, as type: T.Type) async throws -> T {
    let url = baseURL.appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let (data, response) = try await session.data(for: request)

    guard let http = response as? HTTPURLResponse else {
      throw AppError.network(underlying: "Invalid response")
    }

    switch http.statusCode {
    case 200...299:
      do {
        return try decoder.decode(T.self, from: data)
      } catch {
        throw AppError.decoding(underlying: error.localizedDescription)
      }
    case 401:
      throw AppError.unauthorized
    case 404:
      throw AppError.notFound
    default:
      throw AppError.network(underlying: "HTTP \(http.statusCode)")
    }
  }
}
