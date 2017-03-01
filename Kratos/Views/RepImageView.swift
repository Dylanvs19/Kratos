//
//  RepImageView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepImageView: UIImageView {
    var person: Person?
    var lightPerson: LightPerson?
    var url: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
    }
    
    func set(image: UIImage) {
        self.image = image
        self.contentMode = .scaleAspectFill
        self.addRepImageViewBorder()
    }
    
    func setRepresentative(person: Person) {
        self.person = person
        if let url = person.imageURL {
            loadRepImage(from: url)
        }
    }
    
    func setLightPerson(lightPerson: LightPerson) {
        self.lightPerson = lightPerson
        if let url = lightPerson.imageURL {
            loadRepImage(from: url)
        }
    }
    
    func loadRepImage(from url: String) {
        UIImage.downloadedFrom(url, onCompletion: { [weak self] (image) -> (Void) in
            guard let image = image else {
                self?.image = self?.person?.currentChamber?.toImage() ?? #imageLiteral(resourceName: "CongressLogo")
                return
            }
            self?.set(image: image)
        })
    }
}
