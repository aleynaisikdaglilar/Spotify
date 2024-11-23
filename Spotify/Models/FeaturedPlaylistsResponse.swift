//
//  FeaturedPlaylistsResponse.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 9.11.2024.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct CategoryPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlist]
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.items = try container.decodeIfPresent([Playlist].self, forKey: .items) ?? []
        }
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
