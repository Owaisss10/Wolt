//
//  ErrorStateView.swift
//  Wolt
//
//  Created by Awais Akram on 13.7.2024.
//

import UIKit

class ErrorStateView: UIView {

    // MARK: - Setters
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var body: String? {
        didSet {
            bodyLabel.text = body
        }
    }

    // MARK: - UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No data available"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.UI.Fonts.title1
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Something went wrong"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = Constants.UI.Fonts.body
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIandConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUIandConstraints() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(bodyLabel)

        imageView.addConstraints(
            width: Constants.UI.cellErrorStateImageWidth,
            height: Constants.UI.cellErrorStateImageHeight,
            centerX: centerXAnchor,
            centerY: centerYAnchor
        )

        titleLabel.addConstraints(
            top: imageView.bottomAnchor,
            leading: leadingAnchor,
            trailing: trailingAnchor,
            paddingTop: Constants.UI.topPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )

        bodyLabel.addConstraints(
            top: titleLabel.bottomAnchor,
            leading: leadingAnchor,
            trailing: trailingAnchor,
            paddingTop: Constants.UI.topPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )
    }
}
