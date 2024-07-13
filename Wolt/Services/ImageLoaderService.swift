//
//  ImageLoaderService.swift
//  Wolt
//
//  Created by Awais Akram on 8.7.2024.
//

import UIKit
import Combine

class ImageLoaderService {
    static let shared = ImageLoaderService()

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .eraseToAnyPublisher()
    }
}
