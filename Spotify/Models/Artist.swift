//
//  Artist.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 1.11.2024.
//

import Foundation

struct Artist: Codable {
    let id: String?
    let name: String?
    let type: String?
    let external_urls: [String: String]?
}
