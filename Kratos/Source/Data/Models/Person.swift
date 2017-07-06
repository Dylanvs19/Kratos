//
//  Person.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

struct Person: Hashable, Decodable {
    var hashValue: Int {
        return id
    }

    var id: Int
    var firstName: String?
    var lastName: String?
    var currentState: String?
    var currentParty: Party?
    var dob: Date?
    var imageURL: String?
    var twitter: String?
    var youtube: String?
    var gender: String?
    var terms: [Term]?
    var tallies: [LightTally]?
    var biography: String?
    
    var currentDistrict: Int?
    var officialFullName: String?
    var isCurrent: Bool?
    var currentChamber: Chamber?
    var religion: String?
    
    init?(json: [String: Any]) {
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            return nil 
        }
        self.firstName = json["first_name"] as? String
        self.lastName = json["last_name"] as? String
        self.twitter = json["twitter"] as? String
        self.youtube = json["youtube"] as? String
        self.currentState = json["current_state"] as? String
        if let party = json["current_party"] as? String {
            self.currentParty = Party.value(for: party)
        }
        self.imageURL = json["image_url"] as? String
        self.gender = json["gender"] as? String
        if let dob = json["birthday"] as? String {
            self.dob = dob.stringToDate()
        }
        self.currentDistrict = json["current_district"] as? Int
        self.officialFullName = json["official_full_name"] as? String
        self.biography = json["bio"] as? String
        self.religion = json["religion"] as? String
        self.isCurrent = json["is_current"] as? Bool
        if let chamber = json["current_office"] as? String {
            self.currentChamber = Chamber.chamber(value: chamber)
        }
        if let termArray = json["terms"] as? [[String: AnyObject]] {
            self.terms = termArray.map({ (dictionary) -> Term? in
                let term = Term(json: dictionary)
                if (term?.isCurrent ?? false) {
                    if self.currentState == nil {
                        self.currentState = term?.state
                    }
                    if self.currentChamber == nil {
                        self.currentChamber = term?.representativeType?.toChamber()
                    }
                    if self.currentParty == nil {
                        self.currentParty = term?.party
                    }
                    if self.currentDistrict == nil {
                        self.currentDistrict = term?.district
                    }
                }
                return term
            }).flatMap({$0}).sorted(by: {$0.startDate ?? Date() > $1.startDate ?? Date()})
        }
        if !(isCurrent == true) {
            if self.currentState == nil {
                self.currentState = terms?.first?.state
            }
            if self.currentChamber == nil {
                self.currentChamber = terms?.first?.representativeType?.toChamber()
            }
            if self.currentParty == nil {
                self.currentParty = terms?.first?.party
            }
            if self.currentDistrict == nil {
                self.currentDistrict = terms?.first?.district
            }
        }
    }
    
    func toLightPerson() -> LightPerson {
        var person = LightPerson(with: id)
        person.firstName = firstName
        person.lastName = lastName
        person.district = currentDistrict
        person.party = currentParty
        person.state = currentState
        person.representativeType = currentChamber?.representativeType
        person.imageURL = imageURL
        return person 
    }
    
    var fullName: String? {
        guard let first = firstName,
            let last = lastName else { return nil }
        return first + " " + last
    }
}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.id == rhs.id
}

struct LightPerson: Hashable {
    var hashValue: Int {
        return id
    }
    
    var firstName: String?
    var lastName: String?
    var id: Int
    var imageURL: String?
    var state: String?
    var party: Party?
    var representativeType: RepresentativeType?
    var district: Int?
    var isCurrent: Bool?
    
    init?(from json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            return nil
        }
        self.imageURL = json["image_url"] as? String
        self.firstName = json["first_name"] as? String
        self.lastName = json["last_name"] as? String
        self.isCurrent = json["is_current"] as? Bool
        if let party = json["current_party"] as? String {
            self.party = Party.value(for: party)
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
    init(with id: Int) {
        self.id = id
    }
}

enum Party {
    case republican
    case democrat
    case independent
    
    static func value(for string: String?) -> Party? {
        guard let string = string else { return nil }
        switch string {
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
    var capitalLetter: String {
        switch self {
        case .democrat:
            return "D"
        case .republican:
            return "R"
        case .independent:
            return "I"
        }
    }
    var short: String {
        switch self {
        case .democrat:
            return "Dem"
        case .republican:
            return "Rep"
        case .independent:
            return "Ind"
        }
    }
    
    var long: String {
        switch self {
        case .democrat:
            return "Democrat"
        case .republican:
            return "Republican"
        case .independent:
            return "Independent"
        }
    }
    
    var color: UIColor {
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
    
    func toChamber() -> Chamber {
        switch self {
        case .representative:
            return Chamber.house
        case .senator:
            return Chamber.senate
        }
    }
    
    func toImage() -> UIImage {
        switch self {
        case .representative:
            return #imageLiteral(resourceName: "HouseOfRepsLogo")
        case .senator:
            return #imageLiteral(resourceName: "SenateLogo")
        }
    }
}

func ==(lhs: LightPerson, rhs: LightPerson) -> Bool {
    return lhs.id == rhs.id
}

