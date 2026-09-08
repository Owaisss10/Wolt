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

    // MARK: - Variables
    static let reuseIdentifier = "VenueTableViewCell"
    private var cancellables = Set<AnyCancellable>()
    private let networkImageViewLoader = NetworkImageViewLoader()
    weak var delegate: VenueTableViewCellDelegate?

    // MARK: - UI Components
    private let leadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.UI.cellImageCornerRadius
        imageView.layer.borderColor = UIColor.separator.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.backgroundColor = .clear
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
        label.textColor = .systemGray
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

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIandConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUIandConstraints() {
        contentView.addSubview(leadingImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(favoriteButton)

        leadingImageView.addConstraints(
            leading: contentView.leadingAnchor,
            paddingLeading: Constants.UI.horizontalPadding,
            width: Constants.UI.cellLeadingImageWidth,
            height: Constants.UI.cellLeadingImageHeight,
            centerY: contentView.centerYAnchor
        )

        titleLabel.addConstraints(
            top: contentView.topAnchor,
            leading: leadingImageView.trailingAnchor,
            trailing: favoriteButton.leadingAnchor,
            paddingTop: Constants.UI.cellTopPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )

        subtitleLabel.addConstraints(
            top: titleLabel.bottomAnchor,
            leading: leadingImageView.trailingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: favoriteButton.leadingAnchor,
            paddingTop: Constants.UI.cellTopPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingBottom: Constants.UI.bottomPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )

        favoriteButton.addConstraints(
            trailing: contentView.trailingAnchor,
            paddingTrailing: Constants.UI.horizontalPadding,
            width: Constants.UI.cellTrailingImageWidth,
            height: Constants.UI.cellTrailingImageHeight,
            centerY: contentView.centerYAnchor
        )
    }

    // MARK: - Functions
    func configure(restaurant: Restaurant?) {

        let imageUrlString = restaurant?.image?.url
        let title = restaurant?.venue?.name
        let subtitle = restaurant?.venue?.short_description

        favoriteButton.isFavorite = restaurant?.isFavorite ?? false

        if let imageUrlString = imageUrlString,
           let imageUrl = URL(string: imageUrlString) {
            networkImageViewLoader.loadImage(from: imageUrl)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    guard let self = self else { return }
                    if image != nil {
                        self.leadingImageView.image = image
                    } else {
                        self.leadingImageView.image = UIImage(systemName: "photo")
                    }
                }
                .store(in: &cancellables)
        } else {
            leadingImageView.image = UIImage(systemName: "photo")
        }

        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    @objc private func favoriteButtonTapped() {
        delegate?.didToggleFavorite(for: self)
    }
}
