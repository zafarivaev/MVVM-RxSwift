//
//  DataToImageService.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/23/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

protocol DataToImageConversionService: class {
    func getImage(from data: Data) -> UIImage?
}

class DataToImageConversionServiceImplementation: DataToImageConversionService {
    
    func getImage(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
