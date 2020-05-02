//
//  PhotoDetailViewModelTests.swift
//  UnsplashPhotosTests
//
//  Created by Zafar on 5/2/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import XCTest
import RxSwift

@testable import UnsplashPhotos

class PhotoDetailViewModelTests: XCTestCase {
    
    // MARK: System Under Test
    private var disposeBag: DisposeBag!
    private var sut: PhotoDetailViewModelImplementation!
    private var navigationController: UINavigationController!
    
    // MARK: - Set Up & Tear Down
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        navigationController = UINavigationController()
        sut = PhotoDetailViewModelImplementation(
            photosService: UnsplashPhotosServiceImplementation(),
            photoLoadingService: DataLoadingServiceImplementation(),
            dataToImageService: DataToImageConversionServiceImplementation(),
            coordinator: PhotoDetailCoordinatorImplementation(
                navigationController: navigationController,
                photoId: "C389V--ZZrQ"),
            photoId: "C389V--ZZrQ")
    }
    
    override func tearDown() {
        disposeBag = nil
        navigationController = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - View Model Tests
    func testWhenViewDidLoad_TriesToLoadData() {
        let expectation = XCTestExpectation(description: "Load image data")
        
        sut.viewDidLoad.accept(())
        
        // Initial mock data
        sut.imageRetrievedSuccess
            .subscribe(onNext: { (image) in
                XCTAssertNotNil(image)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        sut.imageRetrievedError
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWhenHasInvalidPhotoId_imageRetrievedError() {
        let expectation = XCTestExpectation(description: "imageRetrievedError")
        
        sut = PhotoDetailViewModelImplementation(
        photosService: UnsplashPhotosServiceImplementation(),
        photoLoadingService: DataLoadingServiceImplementation(),
        dataToImageService: DataToImageConversionServiceImplementation(),
        coordinator: PhotoDetailCoordinatorImplementation(
            navigationController: navigationController,
            photoId: ""),
        photoId: "")
        
        sut.viewDidLoad.accept(())
        
        sut.imageRetrievedError
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
