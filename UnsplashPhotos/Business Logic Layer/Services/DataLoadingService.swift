//
//  PhotoLoadingService.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/15/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RxSwift

protocol DataLoadingService: class {
    func loadData(for urlString: String) -> Observable<Result<Data, Error>>
    func loadData(at index: Int,
                  for urlString: String) -> Observable<Result<Data, Error>>
    func stopLoading(at index: Int)
}

class DataLoadingServiceImplementation: DataLoadingService {
    private var tasks: [Int: Disposable] = [:]
    
    func loadData(at index: Int, for urlString: String) -> Observable<Result<Data, Error>> {
        return Observable.create { [weak self] observer in
            guard let url = URL(string: urlString) else {
                observer.onNext(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            let task = NetworkClient.getData(url)
                .subscribe(onNext: { (result) in
                    switch result {
                    case let .failure(error):
                        observer.onNext(.failure(error))
                    case let .success(data):
                        observer.onNext(.success(data))
                    }
                })
            self?.tasks[index] = task
            
            return Disposables.create {
                task.dispose()
            }
        }
    }
    
    func loadData(for urlString: String) -> Observable<Result<Data, Error>> {
         return Observable.create { observer in
            
            guard let url = URL(string: urlString) else {
                observer.onNext(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            let task = NetworkClient.getData(url)
                .subscribe(onNext: { (result) in
                    switch result {
                    case let .failure(error):
                        observer.onNext(.failure(error))
                    case let .success(data):
                        observer.onNext(.success(data))
                    }
                })
            
            return Disposables.create {
                task.dispose()
            }
        }
    }
    
    func stopLoading(at index: Int) {
        print("Cancel task at index: \(index)")
        tasks[index]?.dispose()
    }
}
