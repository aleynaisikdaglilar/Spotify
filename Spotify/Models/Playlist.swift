//
//  Playlist.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 1.11.2024.
//

import Foundation

struct Playlist: Codable {
    let description: String?
    let external_urls: [String: String]?
    let id: String?
    let images: [APIImage]?
    let name: String?
    let owner: User?
}
