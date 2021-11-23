//
//  PhotosService.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RxSwift

protocol UnsplashPhotosService: AnyObject {
    /// Specify a count
    func getPhotos(pageNumber: Int, perPage: Int) -> Observable<Result<[UnsplashPhoto], Error>>
    
    /// Return a photo by the given **id**
    func getPhoto(id: String) -> Observable<Result<UnsplashPhoto, Error>>
}

class UnsplashPhotosServiceImplementation: UnsplashPhotosService {
    private let networkClient = NetworkClient()
    
    func getPhotos(pageNumber: Int, perPage: Int) -> Observable<Result<[UnsplashPhoto], Error>> {
        return Observable.deferred {
    
            let endpoint = Endpoint.photos(page: pageNumber,
                                           perPage: perPage)
            
            return self.networkClient.getArray([UnsplashPhoto].self,
                                               url: endpoint.url,
                                               headers: endpoint.headers)
        }
    }
    
    func getPhoto(id: String) -> Observable<Result<UnsplashPhoto, Error>> {
        return Observable.deferred {
            
            let endpoint = Endpoint.photo(id: id)
            return self.networkClient.get(UnsplashPhoto.self,
                                          url: endpoint.url,
                                          headers: endpoint.headers,
                                          printURL: true)
        }
    }
}
