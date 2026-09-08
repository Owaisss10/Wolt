//
//  CurrentLocationTableHeaderView.swift
//  Wolt
//
//  Created by Awais Akram on 11.7.2024.
//

import UIKit

class CurrentLocationTableHeaderView: UIView {
    
    // MARK: - Setters
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // MARK: - UI components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nearby restaurants in \n-"
        label.font = Constants.UI.Fonts.title2
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIandConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIandConstraints()
    }
    
    // MARK: - Setup UI
    private func setupUIandConstraints() {
        addSubview(titleLabel)
        
        titleLabel.addConstraints(
            centerX: centerXAnchor,
            centerY: centerYAnchor
        )
    }
}
