//
//  CurrentLocationTableHeaderView.swift
//  Wolt
//
//  Created by Awais Akram on 11.7.2024.
//

import UIKit

class CurrentLocationTableHeaderView: UIView {

    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nearby restaurants in \n-"
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIandConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIandConstraints()
    }

    private func setupUIandConstraints() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
