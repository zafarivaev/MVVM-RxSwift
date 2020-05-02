//
//  PhotosViewModelTests.swift
//  UnsplashPhotosTests
//
//  Created by Zafar on 5/1/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import XCTest
import RxSwift
@testable import UnsplashPhotos

class PhotosViewModelTests: XCTestCase {
    
    // MARK: System Under Test
    private var disposeBag: DisposeBag!
    private var sut: PhotosViewModelImplementation!
    private var navigationController: UINavigationController!
    
    // MARK: - Set Up & Tear Down
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        navigationController = UINavigationController()
        sut = PhotosViewModelImplementation(
            photosService: UnsplashPhotosServiceImplementation(),
            photoLoadingService: DataLoadingServiceImplementation(),
            dataToImageService: DataToImageConversionServiceImplementation(),
            coordinator: PhotosCoordinatorImplementation(navigationController: navigationController)
        )
    }
    
    override func tearDown() {
        disposeBag = nil
        navigationController = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - View Model Tests
    func testWhenWillDisplayCellTriesToLoadData() {
        
        let expectation = XCTestExpectation(description: "Load image data")
        
        // Initial mock data
        sut.unsplashPhotos.accept(
            [
                UnsplashPhoto(id: "",
                           description: "",
                           altDescription: "",
                           urls: Urls(
                            raw: "https://unsplash.com/photos/wxZJ-V6DPKc",
                            full: "https://unsplash.com/photos/wxZJ-V6DPKc",
                            regular: "https://unsplash.com/photos/wxZJ-V6DPKc",
                            small: "https://unsplash.com/photos/wxZJ-V6DPKc",
                            thumb: "https://unsplash.com/photos/wxZJ-V6DPKc")
                           )
            ]
        )
        
        sut.willDisplayCellAtIndex
            .accept(0)
        
        sut.imageRetrievedError
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (index) in
                XCTAssertEqual(index, 0)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        sut.imageRetrievedSuccess
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (image, index) in
                XCTAssertNotNil(image)
                XCTAssertEqual(index, 0)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWhenWillDisplayCellGetsNilUrl_imageRetrievedError_isEmitted() {
        let expectation = XCTestExpectation(description: "imageRetrievedError emitted")
        
        // Initial mock data
        sut.unsplashPhotos.accept(
            [
                UnsplashPhoto(id: "",
                              description: "",
                              altDescription: "",
                              urls: nil)
            ]
        )
        
        sut.willDisplayCellAtIndex.accept(0)
       
        
        sut.imageRetrievedError
            .subscribe(onNext: { (index) in
                XCTAssertEqual(index, 0)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWhenInitializedPageNumberIs1() {
        let expectation = XCTestExpectation(description: "Observe the page number value")
        
        sut.pageNumberObs
            .subscribe(onNext: { (value) in
                XCTAssertEqual(value, 1)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWhenScrollsToBottomPageNumberIncreases() {
        let expectation = XCTestExpectation(description: "Push event onto the didScrollToTheBottom")
        
        sut.didScrollToTheBottom.accept(())
        
        sut.pageNumberObs
            .subscribe(onNext: { (value) in
                XCTAssertEqual(value, 2)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewDidLoad_isLoadingFirstPage_getsTrueValue() {
        
        let expectation = XCTestExpectation(description: "isLoadingFirstPage accepts true value")
        
        sut.viewDidLoad.accept(())
        
        sut.isLoadingFirstPage
            .subscribe(onNext: { (value) in
                XCTAssertEqual(value, true)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAfterLoadedPhotos_isLoadingFirstPage_isFalse() {
        let expectation = XCTestExpectation(description: "isLoadingFirstPage is false")
        
        sut.unsplashPhotos
            .filter { !$0.isEmpty }
            .flatMap({ [unowned self] _ -> Observable<Bool> in
                return self.sut.isLoadingFirstPage.asObservable()
            })
            .subscribe(onNext: { (value) in
                
                XCTAssertEqual(value, false)
                
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        sut.viewDidLoad.accept(())
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testWhenLoadingMorePhotos_isLoadingAdditionalPhotos_getsTrueValue() {
        let expectation = XCTestExpectation(description: "isLoadingFirstPage accepts true value")
        
        sut.isLoadingAdditionalPhotos
            .filter { $0 != false }
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        sut.didScrollToTheBottom.accept(())
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAfterLoadedMorePhotos_isLoadingAdditionalPhotos_isFalse() {
        let expectation = XCTestExpectation(description: "isLoadingAdditionalPhotos is false")
        
        sut.unsplashPhotos
            .filter { !$0.isEmpty }
            .flatMap({ [unowned self] _ -> Observable<Bool> in
                return self.sut.isLoadingAdditionalPhotos.asObservable()
            })
            .subscribe(onNext: { (value) in
                XCTAssertEqual(value, false)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        sut.didScrollToTheBottom.accept(())
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
}
