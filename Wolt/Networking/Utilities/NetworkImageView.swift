//
//  NetworkImageView.swift
//  Wolt
//
//  Created by Awais Akram on 8.7.2024.
//

import UIKit
import Combine

class NetworkImageViewLoader {

    private var cache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return Just(cachedImage)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.cache.setObject(image, forKey: url.absoluteString as NSString)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func cancelImageLoad() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
}
