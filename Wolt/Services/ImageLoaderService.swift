//
//  ImageLoaderService.swift
//  Wolt
//
//  Created by Awais Akram on 8.7.2024.
//

import UIKit
import Combine

class ImageLoaderService {
    // MARK: - Variables
    static let shared = ImageLoaderService()

    // MARK: - Functions
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .eraseToAnyPublisher()
    }
}
