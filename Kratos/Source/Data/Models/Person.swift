//
//  Person.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/20/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

struct Person: Hashable, JSONDecodable {
    var hashValue: Int {
        return id
    }

    var id: Int
    var firstName: String
    var lastName: String
    var currentState: State
    var currentParty: Party?
    var dob: Date?
    var imageURL: String?
    var twitter: String?
    var youtube: String?
    var gender: String?
    var terms: [Term]?
    var biography: String?
    
    var currentDistrict: District?
    var officialFullName: String?
    var isCurrent: Bool?
    var currentChamber: Chamber
    var religion: String?
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let first = json["first_name"] as? String,
              let last = json["last_name"] as? String,
              let stateString = json["current_state"] as? String,
              let state =  State(rawValue: stateString),
              let chamberString = json["current_office"] as? String,
              let chamber =  Chamber.chamber(value: chamberString) else { return nil }
        
        self.id = id
        self.firstName = first
        self.lastName = last
        self.twitter = json["twitter"] as? String
        self.youtube = json["youtube"] as? String
        self.currentState = state
        if let party = json["current_party"] as? String {
            self.currentParty = Party.value(for: party)
        }
        self.imageURL = json["image_url"] as? String
        self.gender = json["gender"] as? String
        if let dob = json["birthday"] as? String {
            self.dob = dob.date
        }
        if let district = json["current_district"] as? Int {
            self.currentDistrict = District(state: state, district: district)
        }
        self.officialFullName = json["official_full_name"] as? String
        self.biography = json["bio"] as? String
        self.religion = json["religion"] as? String
        self.isCurrent = json["is_current"] as? Bool
        self.currentChamber = chamber
        if let termArray = json["terms"] as? [[String: AnyObject]] {
            self.terms = termArray.map { (dictionary) -> Term? in
                let term = Term(json: dictionary)
                if (term?.isCurrent ?? false) {
                        if self.currentParty == nil {
                            self.currentParty = term?.party
                        }
                        if let district = term?.district,
                            self.currentDistrict == nil {
                            self.currentDistrict = District(state: state, district: district)
                        }
                    }
                    return term
                }
                .flatMap({$0})
                .sorted(by: {$0.startDate ?? Date() > $1.startDate ?? Date()})
        }
        if !(isCurrent == true) {
            if self.currentParty == nil {
                self.currentParty = terms?.first?.party
            }
            if self.currentDistrict == nil {
                if let district = terms?.first?.district,
                    self.currentDistrict == nil {
                    self.currentDistrict = District(state: state, district: district)
                }
            }
        }
    }
    
    var lightPerson: LightPerson {
        var person = LightPerson(with: id,
                                 first: firstName,
                                 last: lastName,
                                 state: currentState)
        person.district = currentDistrict
        person.party = currentParty
        person.representativeType = currentChamber.representativeType
        person.imageURL = imageURL
        return person 
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.id == rhs.id
}

struct LightPerson: Hashable {
    var hashValue: Int {
        return id
    }
    
    var id: Int
    var firstName: String
    var lastName: String
    var imageURL: String?
    var state: State
    var party: Party?
    var representativeType: RepresentativeType?
    var district: District?
    var isCurrent: Bool?
    
    init?(from json: [String: AnyObject]) {
        guard let id = json["id"] as? Int,
            let first = json["first_name"] as? String,
            let last = json["last_name"] as? String,
            let stateString = json["current_state"] as? String,
            let state = State(rawValue: stateString.trimmingCharacters(in: CharacterSet.decimalDigits)) else { return nil }
        
        self.id = id
        self.firstName = first
        self.lastName = last
        self.state = state
        
        if let district = json["current_district"] as? Int {
            self.district = District(state: state, district: district)
        }
        self.imageURL = json["image_url"] as? String
        self.isCurrent = json["is_current"] as? Bool
        if let party = json["current_party"] as? String {
            self.party = Party.value(for: party)
        }
        self.representativeType = self.district != nil ? .representative : .senator
    }
    
    init(with id: Int, first: String, last: String, state: State) {
        self.id = id
        self.firstName = first
        self.lastName = last
        self.state = state
    }
    
    var fullName: String {
        return firstName + " " + lastName
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
    
    var color: Color {
        switch self {
        case .democrat:
            return .kratosBlue
        case .republican:
            return .kratosRed
        case .independent:
            return .gray
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

func !=(lhs: LightPerson, rhs: LightPerson) -> Bool {
    return !(lhs == rhs)
}

