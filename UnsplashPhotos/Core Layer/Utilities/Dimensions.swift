//
//  Dimensions.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

struct Dimensions {
    static let screenWidth: CGFloat
        = UIScreen.main.bounds.width
    static let screenHeight: CGFloat
        = UIScreen.main.bounds.height
    
    static let photosItemSize
        = CGSize(width: Dimensions.screenWidth * 0.45,
                 height: Dimensions.screenWidth * 0.45)
}
