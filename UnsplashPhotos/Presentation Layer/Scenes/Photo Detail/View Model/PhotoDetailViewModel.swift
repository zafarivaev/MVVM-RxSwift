//
//  PhotoDetailViewModel.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/15/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RxSwift
import RxRelay

/// View model interface that is visible to the PhotoDetailViewController
protocol PhotoDetailViewModel: class {
    // Input
    var viewDidLoad: PublishRelay<Void> { get }
    
    // Output
    var isLoading: BehaviorRelay<Bool> { get }
    var imageRetrievedError: PublishRelay<Void> { get }
    var imageRetrievedSuccess: PublishRelay<UIImage> { get }
    var description: PublishRelay<String> { get }
}

final class PhotoDetailViewModelImplementation: PhotoDetailViewModel {
    
    // MARK: - Input
    let viewDidLoad = PublishRelay<Void>()
    
    // MARK: - Output
    let isLoading = BehaviorRelay<Bool>(value: false)
    let imageRetrievedError = PublishRelay<Void>()
    let imageRetrievedSuccess = PublishRelay<UIImage>()
    let description = PublishRelay<String>()
    
    // MARK: - Private Properties
    private let photosService: UnsplashPhotosService
    private let photoLoadingService: DataLoadingService
    private let dataToImageService: DataToImageConversionService
    private let coordinator: PhotoDetailCoordinator
    
    private let disposeBag = DisposeBag()
    private let unsplashPhoto = PublishRelay<UnsplashPhoto>()
    private let photoId: String
    
    // MARK: - Initialization
    init(photosService: UnsplashPhotosService,
         photoLoadingService: DataLoadingService,
         dataToImageService: DataToImageConversionService,
         coordinator: PhotoDetailCoordinator,
         photoId: String) {
        
        self.photosService = photosService
        self.photoLoadingService = photoLoadingService
        self.dataToImageService = dataToImageService
        self.coordinator = coordinator
        
        self.photoId = photoId
        
        bindOnViewDidLoad()
        bindOnPhotoRetrieval()
    }
    
    private func bindOnViewDidLoad() {
        viewDidLoad
            .do(onNext: { [unowned self] _ in
                self.getPhoto()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func bindOnPhotoRetrieval() {
        // Bind to description
        unsplashPhoto
            .flatMap({ (unsplashPhoto) -> Observable<String?> in
                var description: String?
                
                if let photoDescription = unsplashPhoto.description {
                    description = photoDescription
                } else if let alternativeDescription = unsplashPhoto.altDescription {
                    description = alternativeDescription
                }
                
                return Observable.just(description)
            })
            .compactMap { $0 }
            .bind(to: description)
            .disposed(by: disposeBag)
        
        // Bind to image
        unsplashPhoto
            .flatMap { [weak self] (photo) -> Observable<Result<Data, Error>> in
                guard let self = self else { return .empty() }
                
                if let photoURL = photo.urls?.regular {
                    return self.photoLoadingService
                        .loadData(for: photoURL)
                        .observeOn(
                            ConcurrentDispatchQueueScheduler(qos: .background)
                    )
                } else {
                    self.imageRetrievedError.accept(())
                    return Observable.of(.failure(NetworkError.decodingFailed))
                }
            }
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            })
            .map({ [weak self] (result) -> UIImage? in
                
                var unsplashImage: UIImage?
                
                switch result {
                case let .success(data):
                    if let image = self?.dataToImageService.getImage(from: data) {
                         unsplashImage = image
                    }
                default: break
                }
                
                return unsplashImage
            })
            .compactMap { $0 }
            .bind(to: imageRetrievedSuccess)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Service Methods
    private func getPhoto() {
        isLoading.accept(true)
        
        photosService.getPhoto(id: photoId)
            .compactMap({ [weak self] (result) in
                
                switch result {
                case let .success(photo):
                    return photo
                case .failure(_):
                    self?.imageRetrievedError.accept(())
                    return nil
                }
                
            })
            .bind(to: unsplashPhoto)
            .disposed(by: disposeBag)
    }
    
}
