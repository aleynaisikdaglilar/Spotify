//
//  SettingsModels.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 8.11.2024.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
