//
//  HomeItemDTO.swift
//  HomeFeature · Data layer
//

import Foundation

struct HomeItemDTO: Decodable, Sendable {
  let id: String
  let title: String
  let createdAt: Date

  func toDomain() -> HomeItem {
    HomeItem(id: id, title: title, createdAt: createdAt)
  }
}
