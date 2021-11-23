//
//  PhotosViewModel.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RxSwift
import RxCocoa

/// View model interface that is visible to the PhotosViewController
protocol PhotosViewModel: class {
    // Input
    var viewDidLoad: PublishRelay<Void>
    { get }
    var willDisplayCellAtIndex: PublishRelay<Int>
    { get }
    var didEndDisplayingCellAtIndex: PublishRelay<Int>
    { get }
    var didChoosePhotoWithId: PublishRelay<String>
    { get }
    var didScrollToTheBottom: PublishRelay<Void>
    { get }
    
    // Output
    var isLoadingFirstPage: BehaviorRelay<Bool>
    { get }
    var isLoadingAdditionalPhotos: BehaviorRelay<Bool>
    { get }
    var unsplashPhotos: BehaviorRelay<[UnsplashPhoto]>
    { get }
    var imageRetrievedSuccess: PublishRelay<(UIImage, Int)>
    { get }
    var imageRetrievedError: PublishRelay<Int>
    { get }
}

final class PhotosViewModelImplementation: PhotosViewModel {
    
    // MARK: - Private Properties
    private let photosService: UnsplashPhotosService
    private let photoLoadingService: DataLoadingService
    private let dataToImageService: DataToImageConversionService
    private let coordinator: PhotosCoordinator
    
    private let disposeBag = DisposeBag()
    private let pageNumber = BehaviorRelay<Int>(value: 1)
    lazy var pageNumberObs = pageNumber.asObservable()
    
    // MARK: - Input
    let viewDidLoad
        = PublishRelay<Void>()
    let didChoosePhotoWithId
        = PublishRelay<String>()
    let willDisplayCellAtIndex
        = PublishRelay<Int>()
    let didEndDisplayingCellAtIndex
        = PublishRelay<Int>()
    let didScrollToTheBottom
        = PublishRelay<Void>()
    
    // MARK: - Output
    let isLoadingFirstPage
        = BehaviorRelay<Bool>(value: false)
    let isLoadingAdditionalPhotos
        = BehaviorRelay<Bool>(value: false)
    let unsplashPhotos
        = BehaviorRelay<[UnsplashPhoto]>(value: [])
    let imageRetrievedSuccess
        = PublishRelay<(UIImage, Int)>()
    let imageRetrievedError
        = PublishRelay<Int>()
    
    // MARK: - Initialization
    init(photosService: UnsplashPhotosService,
         photoLoadingService: DataLoadingService,
         dataToImageService: DataToImageConversionService,
         coordinator: PhotosCoordinator) {
        
        self.photosService = photosService
        self.photoLoadingService = photoLoadingService
        self.dataToImageService = dataToImageService
        self.coordinator = coordinator
        
        bindOnViewDidLoad()
        bindOnWillDisplayCell()
        bindOnDidEndDisplayingCell()
        bindOnDidScrollToBottom()
        bindPageNumber()
        
        bindOnDidChoosePhoto()
    }
    
    // MARK: - Bindings
    private func bindOnViewDidLoad() {
        viewDidLoad
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                self.getPhotos()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func bindOnWillDisplayCell() {
        willDisplayCellAtIndex
            .customDebug(identifier: "willDisplayCellAtIndex")
            .filter({ [unowned self] index in
                self.unsplashPhotos.value.indices.contains(index)
            })
            .map { [unowned self] index in
                (index, self.unsplashPhotos.value[index])
            }
            .compactMap({ [weak self] (index, photo) in
                guard let urlString = photo.urls?.regular else {
                    DispatchQueue.main.async {
                        self?.imageRetrievedError.accept(index)
                    }
                    return nil
                }
                return (index, urlString)
            })
            .flatMap({ [unowned self] (index, urlString) in
                self.photoLoadingService
                    .loadData(at: index, for: urlString)
                    .observeOn(
                        ConcurrentDispatchQueueScheduler(qos: .background)
                    )
                    .concatMap { (result) -> Observable<(Int, Data?, Error?)> in
                        switch result {
                        case let .failure(error):
                            return Observable.of((index, nil, error))
                        case let .success(data):
                            return Observable.of((index, data, nil))
                        }
                        
                    }
            })
            .subscribe(onNext: { [weak self] (index, data, error) in
                guard let self = self else { return }
                
                guard let imageData = data,
                    let image = self.dataToImageService
                        .getImage(from: imageData) else {
                    self.imageRetrievedError.accept(index)
                    return
                }
            
                 self.imageRetrievedSuccess
                    .accept((image, index))
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOnDidEndDisplayingCell() {
        didEndDisplayingCellAtIndex
            .subscribe(onNext: { [weak self] (index) in
                guard let self = self else { return }
                
                self.photoLoadingService.stopLoading(at: index)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOnDidScrollToBottom() {
        didScrollToTheBottom
            .flatMap({ [unowned self] _ -> Observable<Int> in
                let newPageNumber = self.pageNumber.value + 1
                return Observable.just(newPageNumber)
            })
            .bind(to: pageNumber)
            .disposed(by: disposeBag)
    }
    
    private func bindPageNumber() {
        pageNumber
            .subscribe(onNext: { [weak self] _ in
                self?.getPhotos()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOnDidChoosePhoto() {
        didChoosePhotoWithId
            .subscribe(onNext: { [unowned self] (id) in
                self.coordinator.pushToPhotoDetail(with: id)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Service Methods
    private func getPhotos() {
        if pageNumber.value == 1 {
            isLoadingFirstPage.accept(true)
        } else {
            isLoadingAdditionalPhotos.accept(true)
        }
        
        photosService.getPhotos(pageNumber: pageNumber.value, perPage: 30)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }

                if self.pageNumber.value == 1 {
                    self.isLoadingFirstPage.accept(false)
                } else {
                    self.isLoadingAdditionalPhotos
                        .accept(false)
                }
            })
            .compactMap({ (result) -> [UnsplashPhoto] in
                switch result {
                case .failure(_):
                    return []
                case let .success(unplashPhotos):
                    return unplashPhotos
                }
            })
            .filter { !$0.isEmpty }
            .flatMap({ [unowned self] (unsplashPhotos) -> Observable<[UnsplashPhoto]> in
                
                var photos: [UnsplashPhoto] = []
                
                // Add previously fetched photos to the array
                let existingPhotos = self.unsplashPhotos.value
                if !existingPhotos.isEmpty {
                    photos.append(contentsOf: existingPhotos)
                }
                
                // Add newly fetched photos to the array
                photos.append(contentsOf: unsplashPhotos)
                
                return Observable.just(photos)
            })
            .bind(to: unsplashPhotos)
            .disposed(by: disposeBag)
    }
}

