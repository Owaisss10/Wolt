//
//  FavoriteButton.swift
//  Wolt
//
//  Created by Awais Akram on 11.7.2024.
//

import UIKit

class FavoriteButton: UIButton {

    // MARK: - Setters
    var isFavorite: Bool = false {
        didSet {
            updateImage()
        }
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(animateButton), for: .touchUpInside)
        updateImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(animateButton), for: .touchUpInside)
        updateImage()
    }

    // MARK: - Functions
    private func updateImage() {
        let filledImage = UIImage(named: "favorite_filled")?.withRenderingMode(.alwaysTemplate)
        let unfilledImage = UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
        let image = isFavorite ? filledImage : unfilledImage
        tintColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        setImage(image, for: .normal)
    }

    @objc private func animateButton() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.5, 0.8, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.3, 0.7, 1.0]
        scaleAnimation.duration = 0.4

        let colorAnimation = CAKeyframeAnimation(keyPath: "opacity")
        colorAnimation.values = [0.2, 1.0]
        colorAnimation.keyTimes = [0.3, 1.0]
        colorAnimation.duration = 0.4

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, colorAnimation]
        groupAnimation.duration = 0.4

        self.layer.add(groupAnimation, forKey: "favoriteButtonAnimation")
    }
}
