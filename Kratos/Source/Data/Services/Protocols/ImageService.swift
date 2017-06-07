//
//  ImageService.swift
//  Kratos
//
//  Created by Dylan Straughan on 5/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import RxSwift

protocol ImageService {
    func fetchImage(for urlString: String) -> Observable<UIImage>
}
