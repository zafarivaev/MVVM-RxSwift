//
//  NetworkClient.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RxSwift

final class NetworkClient {
    typealias Headers = [String: Any]
    
    // MARK: - Generic GET
    func get<T: Decodable>(_ type: T.Type,
                           url: URL,
                           headers: Headers = [:],
                           printURL: Bool = false)
        -> Observable<Result<T, Error>> {

            return Observable.create { observer in

                var urlRequest = URLRequest(url: url)
                
                headers.forEach { (key, value) in
                    if let value = value as? String {
                        urlRequest.addValue(value,
                                            forHTTPHeaderField: key)
                    }
                }

                if printURL {
                    print(urlRequest.url!.absoluteString)
                }

                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    guard let data = data,
                        let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                            if let error = error {
                                observer.onNext(
                                    .failure(error)
                                )
                            } else {
                                observer.onNext(
                                    .failure(NetworkError.unknown)
                                )
                            }
                            return
                    }

                    do {
                        let model = try JSONDecoder()
                            .decode(type, from: data)
                        
                        observer.onNext(
                            .success(model)
                        )
                    } catch {
                        observer.onNext(
                            .failure(NetworkError.decodingFailed)
                        )
                    }

                }

                task.resume()

                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
    // MARK: - Generic GET Array
    func getArray<T: Decodable>(_ type: [T].Type,
                                url: URL,
                                headers: Headers = [:],
                                printURL: Bool = false)
        -> Observable<Result<[T], Error>> {
            
            return Observable.create { observer in
                
                var urlRequest = URLRequest(url: url)
                
                headers.forEach { (key, value) in
                    if let value = value as? String {
                        urlRequest.addValue(value,
                                            forHTTPHeaderField: key)
                    }
                }
                
                if printURL {
                    print(urlRequest.url!.absoluteString)
                }
                
                let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    
                    guard let data = data,
                        let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                            
                            if let error = error {
                                observer.onNext(
                                    .failure(error)
                                )
                            } else {
                                observer.onNext(
                                    .failure(NetworkError.unknown)
                                )
                            }
                            return
                    }
                    
                    do {
                        let model = try JSONDecoder()
                            .decode(type, from: data)
                        
                        observer.onNext(
                            .success(model)
                        )
                    } catch {
                        observer.onNext(
                            .failure(NetworkError.decodingFailed)
                        )
                    }
                    
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
    // MARK: - Basic GET Data
    /// This method does not depend on the baseURL property, so it makes sense to use it without instantiating the NetworkClient
    static func getData(_ url: URL, printURL: Bool = false) -> Observable<Result<Data, Error>> {
        return Observable.create { observer in
            
            if printURL {
                print(url.absoluteString)
            }
            
            let session = URLSession(configuration: .ephemeral)
                
            let task = session.dataTask(with: url) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                        if let error = error {
                            observer.onNext(
                                .failure(error)
                            )
                        } else {
                            observer.onNext(
                                .failure(NetworkError.unknown)
                            )
                        }
                        return
                }
                
                observer.onNext(.success(data))
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
