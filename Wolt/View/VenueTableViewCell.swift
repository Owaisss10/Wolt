//
//  VenueTableViewCell.swift
//  Wolt
//
//  Created by Awais Akram on 8.7.2024.
//

import UIKit
import Combine

protocol VenueTableViewCellDelegate: AnyObject {
    func didToggleFavorite(for cell: VenueTableViewCell)
}

class VenueTableViewCell: UITableViewCell {

    static let reuseIdentifier = "VenueTableViewCell"
    private var cancellables = Set<AnyCancellable>()
    private let networkImageViewLoader = NetworkImageViewLoader()
    weak var delegate: VenueTableViewCellDelegate?

    // UI Components
    private let leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.UI.Fonts.headline
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.UI.Fonts.subheadline
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let favoriteButton: FavoriteButton = {
        let button = FavoriteButton()
        button.isFavorite = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func favoriteButtonTapped() {
        delegate?.didToggleFavorite(for: self)
    }

    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIandConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup UI
    private func setupUIandConstraints() {
        contentView.addSubview(leadingImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            leadingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            leadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leadingImageView.widthAnchor.constraint(equalToConstant: 60),
            leadingImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -15),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: 15),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -15),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.UI.bottomPadding),

            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(restaurant: Restaurant?) {

        let imageUrlString = restaurant?.image?.url
        let title = restaurant?.venue?.name
        let subtitle = restaurant?.venue?.short_description

        favoriteButton.isFavorite = restaurant?.isFavorite ?? false

        leadingImageView.image = UIImage(systemName: "photo")
        if let imageUrlString = imageUrlString,
           let imageUrl = URL(string: imageUrlString) {
            networkImageViewLoader.loadImage(from: imageUrl)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    guard let self = self else { return }
                    self.leadingImageView.image = image
                }
                .store(in: &cancellables)
        } else {
            leadingImageView.image = UIImage(systemName: "photo")
        }

        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

