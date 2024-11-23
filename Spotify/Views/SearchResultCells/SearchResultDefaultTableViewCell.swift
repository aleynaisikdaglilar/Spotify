//
//  SearchResultDefaultTableViewCell.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 23.11.2024.
//

import UIKit
import SDWebImage

class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageViews: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageViews)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        iconImageViews.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        iconImageViews.layer.cornerRadius = imageSize/2
        iconImageViews.layer.masksToBounds = true
        label.frame = CGRect(x: iconImageViews.right+10, y: 0, width: contentView.width-iconImageViews.right-15, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageViews.image = nil
        label.text = nil
    }
    
    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageViews.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
