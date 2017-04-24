//
//  MainTableViewCellTitleView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/2/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class MainTableViewCellTitleView: UIView, Tappable {
    
    var titleLabel = UILabel()
    var resultTextLabel = UILabel()
    var resultView = UIView()
    var selector: Selector = #selector(viewTapped)
    var tapped: ((LightTally) -> ())?
    var lightTally: LightTally?
    
    func configure(with lightTally: LightTally, tapped: @escaping ((LightTally) -> ())) {
        addTap()
        self.tapped = tapped
        self.lightTally = lightTally

        var title = ""
        if let hold = lightTally.billShortTitle {
            title = hold
            
        } else if let hold = lightTally.billOfficialTitle {
            title = hold
        }
        titleLabel.text = title
        
        if let result = lightTally.result,
           let category = lightTally.category,
               category == .passage,
               result == .billPassed || result == .failed {
            resultView.backgroundColor = result == .billPassed ? UIColor.yeaVoteGreen : UIColor.kratosRed
            resultTextLabel.text = lightTally.result?.rawValue
            
        } else {
            resultView.backgroundColor = UIColor.gray
            resultTextLabel.text = "Bill Pending"
        }
        resultView.alpha = 0.7
    }
    
    func viewTapped() {
        if let lightTally = lightTally {
            tapped?(lightTally)
        }
    }
}
