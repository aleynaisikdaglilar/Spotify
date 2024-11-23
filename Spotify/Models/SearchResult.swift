//
//  SearchResult.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 23.11.2024.
//

import Foundation

enum SearchResult {
    case artist(model: Artist?)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
