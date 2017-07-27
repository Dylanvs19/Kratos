//
//  Client+ImageService.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Client: ImageService {
    
    func fetchImage(for urlString: String) -> Observable<UIImage> {
        let target = KratosTarget.url(url: urlString)
        return request(target)
                .observeOn(SerialDispatchQueueScheduler(qos: .background))
                .map {
                    guard let image = UIImage(data: $0) else {
                        self.invalidateCache(for: target)
                        throw KratosError.mappingError(type: .failure)
                    }
                    return image
                }
                .observeOn(MainScheduler.instance)
    }
    
}
