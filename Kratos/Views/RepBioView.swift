//
//  RepBioVIew.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepBioView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with person: Person) {
        if let biography = person.biography {
            let view = SummaryView()
            view.configure(with: biography, title: "Biography")
            stackView.addArrangedSubview(view)
        }
        
        if let terms = person.terms {
            let termsStackView = BillCommitteesView()
            termsStackView.configure(with: terms)
            stackView.addArrangedSubview(termsStackView)
        }
    }
}
