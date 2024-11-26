//
//  NewReleasesResponse.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 9.11.2024.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var itemsArray = try container.nestedUnkeyedContainer(forKey: .items)
            var decodedItems: [Album] = []

            while !itemsArray.isAtEnd {
                if let item = try? itemsArray.decode(Album.self) { // Decode edilebilen değerleri al
                    decodedItems.append(item)
                }
            }

            self.items = decodedItems
        }
}

struct Album: Codable {
    let album_type: String?
    let available_markets: [String]?
    let id: String?
    var images: [APIImage]?
    let name: String?
    let release_date: String?
    let total_tracks: Int?
    let artists: [Artist]?
}
