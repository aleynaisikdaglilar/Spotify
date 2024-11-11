//
//  RecommendationsResponse.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 9.11.2024.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
