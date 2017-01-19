//
//  Person.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

struct Person {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var currentState: String?
    var currentParty: Party?
    var dob: Date?
    var imageURL: String?
    var twitter: String?
    var youtube: String?
    var gender: String?
    var roles: [Role]?
    var tallies: [LightTally]?
    
    init(from json: [String: AnyObject]) {
        self.id = json["id"] as? Int
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        self.twitter = json["twitterid"] as? String
        self.youtube = json["youtubeid"] as? String
        self.currentState = json["current_state"] as? String
        if let party = json["current_party"] as? String {
            self.currentParty = Party.party(value: party)
        }
        self.imageURL = json["image_url"] as? String
        self.gender = json["gender"] as? String
        if let dob = json["birthday"] as? String {
            self.dob = dob.stringToDate()
        }
        if let roleArray = json["roles"] as? [[String: AnyObject]] {
            self.roles = roleArray.map({ (dictionary) -> Role? in
                return Role(json: dictionary)
            }).flatMap({$0})
        }
    }
    
    init() {}
    
    func toLightPerson() -> LightPerson {
        var person = LightPerson()
        person.firstName = firstName
        person.lastName = lastName
        person.district = roles?.first?.district
        person.party = currentParty
        person.state = currentState
        person.representativeType = roles?.first?.representativeType
        person.id = id
        person.imageURL = imageURL
        return person 
    }
}

struct LightPerson {
    
    var firstName: String?
    var lastName: String?
    var id: Int?
    var imageURL: String?
    var state: String?
    var party: Party?
    var representativeType: RepresentativeType?
    var district: Int?
    
    init(from json: [String: AnyObject]) {
        self.id = json["id"] as? Int
        self.imageURL = json["image"] as? String
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        if let party = json["current_party"] as? String {
            self.party = Party.party(value: party)
        }
        if let state = json["current_state"] as? String {
            if state.characters.count > 2 {
                self.representativeType = .representative
                let finalState = state.trimmingCharacters(in: CharacterSet.decimalDigits)
                self.state = finalState
                let district = state.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                self.district = Int(district)
            } else {
                self.representativeType = .senator
                self.state = state
            }
        }
    }
    
    init() {}
}

enum Party: String, RawRepresentable {
    case republican = "Republican"
    case democrat = "Democrat"
    case independent = "Independent"
    
    static func party(value: String) -> Party? {
        switch value {
        case "R", "Republican", "republican":
            return .republican
        case "D", "Democrat", "democrat":
            return .democrat
        case "I", "Independent", "independent":
            return .independent
        default:
            return nil
        }
        
    }
    func capitalLetter() -> String {
        switch self {
        case .democrat:
            return "D"
        case .republican:
            return "R"
        case .independent:
            return "I"
        }
    }
    func short() -> String {
        switch self {
        case .democrat:
            return "Dem"
        case .republican:
            return "Rep"
        case .independent:
            return "Ind"
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .democrat:
            return UIColor.kratosBlue
        case .republican:
            return UIColor.kratosRed
        case .independent:
            return UIColor.gray
        }
    }
}
enum RepresentativeType: String, RawRepresentable {
    case representative = "Representative"
    case senator = "Senator"
    
    func short() -> String {
        switch self {
        case .representative:
            return "Rep"
        case .senator:
            return "Sen"
        }
    }
}

