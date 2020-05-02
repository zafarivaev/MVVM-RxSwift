//
//  Extensions.swift
//  UnsplashPhotos
//
//  Created by Zafar on 4/15/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

import RxSwift

protocol ReuseIdentifiable: class {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String { .init(describing: self) }
}

extension UICollectionViewCell: ReuseIdentifiable {}
extension UITableViewCell: ReuseIdentifiable {}

extension ObservableType {
    public func customDebug(identifier: String) -> Observable<Self.Element> {
       return Observable.create { observer in
           print("subscribed \(identifier)")
           let subscription = self.subscribe { e in
            print("\(identifier)  \(String(describing: e.element))")
               switch e {
               case .next(let value):
                   observer.on(.next(value))

               case .error(let error):
                   observer.on(.error(error))

               case .completed:
                   observer.on(.completed)
               }
           }
           return Disposables.create {
                  print("disposing \(identifier)")
                  subscription.dispose()
           }
       }
   }
}
