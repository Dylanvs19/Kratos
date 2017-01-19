//
//  RepImageView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepImageView: UIImageView, Tappable {
    var person: Person?
    var lightPerson: LightPerson?
    var url: String?
    internal var selector: Selector = #selector(viewTapped)
    var actionBlock: ((Person) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTap()
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
    }
    
    func setRepresentative(person: Person, repInfoViewActionBlock: ((Person) -> ())?) {
        self.person = person
        if let url = person.imageURL {
            loadRepImage(from: url)
        }
        self.actionBlock = repInfoViewActionBlock
    }
    
    func setLightPerson(lightPerson: LightPerson) {
        self.lightPerson = lightPerson
        if let url = lightPerson.imageURL {
            loadRepImage(from: url)
        }
    }
    
    func loadRepImage(from url: String) {
        UIImage.downloadedFrom(url, onCompletion: { (image) -> (Void) in
            guard let image = image else { return }
            self.image = image
            self.contentMode = .scaleAspectFill
            self.addRepImageViewBorder()
        })
    }
    
    func viewTapped() {
        if let person = person {
            actionBlock?(person)
        }
    }
}
