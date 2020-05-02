//
//  PhotosCoordinator.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

protocol PhotosCoordinator: class {
    func pushToPhotoDetail(with photoId: String)
}

class PhotosCoordinatorImplementation: Coordinator {
    unowned let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let photosViewController = PhotosViewController()
        let photosViewModel = PhotosViewModelImplementation(
            photosService: UnsplashPhotosServiceImplementation(),
            photoLoadingService: DataLoadingServiceImplementation(),
            dataToImageService: DataToImageConversionServiceImplementation(),
            coordinator: self
        )
        photosViewController.viewModel = photosViewModel
        
        navigationController
            .pushViewController(photosViewController, animated: true)
    }
}

extension PhotosCoordinatorImplementation: PhotosCoordinator {
    
    func pushToPhotoDetail(with photoId: String) {
        let photoDetailCoordinator = PhotoDetailCoordinatorImplementation(
            navigationController: navigationController,
            photoId: photoId
        )
        
        coordinate(to: photoDetailCoordinator)
    }
}
