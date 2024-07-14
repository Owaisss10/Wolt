//
//  UIViewExtensions.swift
//  Wolt
//
//  Created by Awais Akram on 14.7.2024.
//

import UIKit

extension UIView {

    func addConstraints(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        paddingLeading: CGFloat = 0,
        paddingBottom: CGFloat = 0,
        paddingTrailing: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        widthAnchor: NSLayoutDimension? = nil,
        widthMultiplier: CGFloat = 1,
        heightAnchor: NSLayoutDimension? = nil,
        heightMultiplier: CGFloat = 1,
        centerX: NSLayoutXAxisAnchor? = nil,
        centerY: NSLayoutYAxisAnchor? = nil
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        if let top = top {
            constraints.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }

        if let leading = leading {
            constraints.append(leadingAnchor.constraint(equalTo: leading, constant: paddingLeading))
        }

        if let bottom = bottom {
            constraints.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }

        if let trailing = trailing {
            constraints.append(trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing))
        }

        if let width = width {
            constraints.append(self.widthAnchor.constraint(equalToConstant: width))
        }

        if let height = height {
            constraints.append(self.heightAnchor.constraint(equalToConstant: height))
        }

        if let widthAnchor = widthAnchor {
            constraints.append(self.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier))
        }

        if let heightAnchor = heightAnchor {
            constraints.append(self.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier))
        }

        if let centerX = centerX {
            constraints.append(centerXAnchor.constraint(equalTo: centerX))
        }

        if let centerY = centerY {
            constraints.append(centerYAnchor.constraint(equalTo: centerY))
        }

        NSLayoutConstraint.activate(constraints)
    }
}
