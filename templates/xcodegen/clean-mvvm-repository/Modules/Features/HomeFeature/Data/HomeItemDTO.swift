//
//  HomeItemDTO.swift
//  HomeFeatureData
//
//  Wire-format type. Mapped to the domain entity at the repository boundary.
//

import Foundation
import HomeFeatureDomain

struct HomeItemDTO: Decodable, Sendable {
  let id: String
  let title: String
  let createdAt: Date

  func toDomain() -> HomeItem {
    HomeItem(id: id, title: title, createdAt: createdAt)
  }
}
