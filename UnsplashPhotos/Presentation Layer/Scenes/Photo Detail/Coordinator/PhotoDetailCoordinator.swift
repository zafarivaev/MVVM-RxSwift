//
//  PhotoDetailCoordinator.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/15/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

protocol PhotoDetailCoordinator: class {}

class PhotoDetailCoordinatorImplementation: Coordinator {
    unowned let navigationController: UINavigationController
    let photoId: String
    
    init(navigationController: UINavigationController, photoId: String) {
        self.navigationController = navigationController
        self.photoId = photoId
    }
    
    func start() {
        let photoDetailViewController = PhotoDetailViewController()
        let photoDetailViewModel = PhotoDetailViewModelImplementation(
            photosService: UnsplashPhotosServiceImplementation(),
            photoLoadingService: DataLoadingServiceImplementation(),
            dataToImageService: DataToImageConversionServiceImplementation(),
            coordinator: self,
            photoId: photoId
        )
        photoDetailViewController.viewModel = photoDetailViewModel
        
        navigationController.pushViewController(photoDetailViewController,
                                                animated: true)
    }
}

extension PhotoDetailCoordinatorImplementation: PhotoDetailCoordinator {}

