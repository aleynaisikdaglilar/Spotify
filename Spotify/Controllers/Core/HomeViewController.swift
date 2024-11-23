//
//  ViewController.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 1.11.2024.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]) // 1
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel]) // 2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) // 3
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return createSectionLayout(section: sectionIndex)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings)
        )
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    //    private func fetchData() {
    //        let group = DispatchGroup()
    //        group.enter()
    //        group.enter()
    //        group.enter()
    //
    //        var newReleases: NewReleasesResponse?
    //        var featuredPlaylist: FeaturedPlaylistsResponse?
    //        var recommendations: RecommendationsResponse?
    //
    //        //        New Releases
    //        APICaller.shared.getNewReleases { result in
    //            defer {
    //                group.leave()
    //            }
    //            switch result {
    //            case .success(let model):
    //                newReleases = model
    //            case .failure(let error):
    //                print(error.localizedDescription)
    //            }
    //        }
    //
    //        //        Featured Playlists
    //        APICaller.shared.getFeaturedPlaylists { result in
    //            defer {
    //                group.leave()
    //            }
    //            switch result {
    //            case .success(let model):
    //                featuredPlaylist = model
    //            case .failure(let error):
    //                print(error.localizedDescription)
    //            }
    //        }
    //
    //        //        Recommended Tracks
    //        APICaller.shared.getRecommendedGenders { result in
    //            switch result {
    //            case .success(let model):
    //                let genres = model.genres
    //                var seeds = Set<String>()
    //                while seeds.count < 5 {
    //                    if let random = genres.randomElement() {
    //                        seeds.insert(random)
    //                    }
    //                }
    //
    //                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
    //                    defer {
    //                        group.leave()
    //                    }
    //                    switch recommendedResult {
    //                    case .success(let model):
    //                        recommendations = model
    //                    case .failure(let error):
    //                        print(error.localizedDescription)
    //                    }
    //                }
    //            case .failure(let error):
    //                print(error.localizedDescription)
    //            }
    //        }
    //
    //        group.notify(queue: .main) {
    //            guard let newAlbums = newReleases?.albums.items,
    //                  let playlists = featuredPlaylist?.playlists.items,
    //                  let tracks = recommendations?.tracks else {
    //                fatalError("Models are nil")
    //                return
    //            }
    //
    //            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
    //        }
    //    }
    
    
    private func fetchData() {
        let group = DispatchGroup()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        
        // Fetch all data
        group.enter()
        fetchNewReleases { result in
            defer { group.leave() }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print("Failed to fetch new releases: \(error.localizedDescription)")
            }
        }
        
        group.enter()
        fetchFeaturedPlaylists { result in
            defer { group.leave() }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print("Failed to fetch featured playlists: \(error.localizedDescription)")
            }
        }
        
        group.enter()
        fetchRecommendations { result in
            defer { group.leave() }
            switch result {
            case .success(let model):
                recommendations = model
            case .failure(let error):
                print("Failed to fetch recommendations: \(error.localizedDescription)")
            }
        }
        
        group.notify(queue: .main) {
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks else {
                print("One or more models are nil.")
                return
            }
            
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
    }
    
    // MARK: - API Call Methods
    
    private func fetchNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
        APICaller.shared.getNewReleases(completion: completion)
    }
    
    private func fetchFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        APICaller.shared.getFeaturedPlaylists(completion: completion)
    }
    
    private func fetchRecommendations(completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        APICaller.shared.getRecommendedGenders { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5, let random = genres.randomElement() {
                    seeds.insert(random)
                }
                
                APICaller.shared.getRecommendations(genres: seeds, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    private func configureModels(newAlbums: [Album], playlists: [Playlist], tracks: [AudioTrack]) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name ?? "nil",
                                            artworkURL: URL(string: $0.images?.first?.url ?? "https://upload.wikimedia.org/wikipedia/commons/8/84/Spotify_icon.svg"),
                                            numberOfTracks: $0.total_tracks ?? 0,
                                            artistName: $0.artists?.first?.name ?? "-"
            )
        })))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name ?? "playlist",
                                                 artworkURL: URL(string: $0.images?.first?.url ?? "https://upload.wikimedia.org/wikipedia/commons/8/84/Spotify_icon.svg"),
                                                 creatorName: $0.owner?.display_name ?? "-"
            )
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(name: $0.name ?? "track",
                                                 artistName: $0.artists?.first?.name ?? "-",
                                                 artworkURL: URL(string: $0.album?.images?.first?.url ?? "https://upload.wikimedia.org/wikipedia/commons/8/84/Spotify_icon.svg"))
        })))
        collectionView.reloadData()
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(viewModels: let viewModels):
            return viewModels.count
        case .featuredPlaylists(viewModels: let viewModels):
            return viewModels.count
        case .recommendedTracks(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .featuredPlaylists(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        case .recommendedTracks:
            break
        }
    }
    
    //    TODO: deprecated - aleynaisikdaglilar
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        switch section {
        case 0:
            //        Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //    Vertical group in horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension:.absolute(390)),
                subitem: item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension:.absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            
            //        Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 1:
            //        Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)),
                subitem: item,
                count: 2
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)),
                subitem: verticalGroup,
                count: 1
            )
            
            //        Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
            //        Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension:.absolute(80)),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            //        Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension:.absolute(390)),
                subitem: item,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}

