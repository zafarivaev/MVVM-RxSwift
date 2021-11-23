//
//  UnsplashEndpoints.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import Foundation

extension Endpoint {
    static func photos(page: Int, perPage: Int) -> Self {
        return Endpoint(
            path: "photos",
            queryItems: [
                URLQueryItem(
                    name: "page",
                    value: String(page)
                ),
                URLQueryItem(
                    name: "per_page",
                    value: String(perPage)
                ),
                URLQueryItem(
                    name: "order_by",
                    value: "popular"
                )
            ]
        )
    }
    
    static func photo(id: String) -> Self {
        return Endpoint(path: "photos/\(id)")
    }
}
