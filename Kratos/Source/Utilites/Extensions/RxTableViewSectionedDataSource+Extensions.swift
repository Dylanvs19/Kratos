//
//  RxTableViewSectionedDataSource+Extensions.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/17/18.
//  Copyright © 2018 Dylan Straughan. All rights reserved.
//

import Foundation
import RxDataSources

extension RxTableViewSectionedReloadDataSource {
    public convenience init() {
        self.init( configureCell: { (_, _, _, _) in fatalError("configureCell must be redefined before use") })
    }
}

extension RxTableViewSectionedAnimatedDataSource {
    public convenience init() {
      self.init(configureCell: { (_, _, _, _) in fatalError("configureCell must be redefined before use") })
    }
}
