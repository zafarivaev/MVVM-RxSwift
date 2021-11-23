//
//  Endpoint+URL.swift
//  UnsplashPhotos
//
//  Created by Zafar on 7/12/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import Foundation

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        return url
    }
    
    var headers: [String : Any] {
        return [
            "Content-Type":"application/json",
            "Authorization": "Client-ID \(apiKey)"
        ]
    }
    
    var apiKey: String {
        return "9836d9c4041f5323b2e2921cbe653a3bbce58bdaa1346f68c27a0540c114b807"
    }
}
