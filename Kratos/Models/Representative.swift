//
//  Representative.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

protocol Representative {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var id: Int? { get set }
    var imageURL: String? { get set }
    var district: Int? { get set }
    var state: String? { get set }
    var party: Party? { get set }
    var fullTitle: String? { get set }
    var representativeType: RepresentativeType? { get set }
}

extension Representative {
    
    func parseNameJsonField(json: String?) -> (repType: RepresentativeType?, first: String?, last: String?, party: Party?, state: String?, district: Int?) {
        //"Sen. Sheldon Whitehouse [D-RI]"
        let nameArray = json?.components(separatedBy: " ")
        let count = nameArray?.count ?? 0
        var repType: RepresentativeType?
        if nameArray?[0] == "Sen." {
            repType = .senator
        } else if nameArray?[0] == "Rep." {
            repType = .representative
        }
        
        let firstName = nameArray?[1]
        
        let lastName = nameArray?[(count - 2)]
        var party: Party?
        var state: String?
        var district: Int?
        
        if let partyStateArray = nameArray?[(count - 1)].components(separatedBy: "-") {
            if partyStateArray[0] == "[R" {
                party = .republican
            } else if partyStateArray[0] == "[D" {
                party = .democrat
            } else {
                party = .independent
            }
            
            if partyStateArray[1].characters.count == 3 {
                let stateString = partyStateArray[1].replacingOccurrences(of: "]", with: "")
                if InputValidation.validateState(stateString) {
                    state = stateString
                }
            } else if partyStateArray[1].characters.count == 4 {
                let stateString = partyStateArray[1].replacingOccurrences(of: "]", with: "").trimmingCharacters(in: .numbers)
                if InputValidation.validateState(stateString) {
                    state = stateString
                }
                let districtString = partyStateArray[1].replacingOccurrences(of: "]", with: "").trimmingCharacters(in: .letters)
                district = Int(districtString)
            }
        }
        return (repType: repType, first: firstName, last: lastName, party: party, state: state, district: district)
    }
}

enum Party: String, RawRepresentable {
    case republican = "Republican"
    case democrat = "Democrat"
    case independent = "Independent"
}
enum RepresentativeType: String, RawRepresentable {
    case representative = "Representative"
    case senator = "Senator"
}

struct DetailedRepresentative: Representative {
    
    // From Role API
    var state: String?
    var roleType: String?
    var leadershipTitle: String?
    var description: String?
    var district: Int?
    var phoneNumber: String?
    var title: String?
    var website: String?
    var party: Party?
    var imageURL: String?
    var fullTitle: String?
    
    // From Person API
    var id: Int?
    var firstName: String?
    var lastName: String?
    var twitterHandle: String?
    var representativeType : RepresentativeType?
    var votes: [Vote]?
    
    init(from json: [String: AnyObject]) {
       
        self.state = json["state"] as? String
        self.website = json["website"] as? String
        if let roleType = json["role_type_label"] as? String {
           self.representativeType = roleType == "Representative" ? .representative : .senator
        }
        if let repParty = json["party"] as? String {
            switch repParty {
            case "Republican":
                party = .republican
            case "Democrat":
                party = .democrat
            case "Independent":
                party = .independent
            default:
                break
            }
        }
        self.leadershipTitle = json["leadership_title"] as? String
        self.description = json["description"] as? String
        self.district = json["district"] as? Int
        self.phoneNumber = json["phone"] as? String
        self.title = json["title"] as? String
        self.website = json["website"] as? String
        self.id = json["person"]?["id"] as? Int
        self.firstName = json["person"]?["firstname"] as? String
        self.lastName = json["person"]?["lastname"] as? String
        self.twitterHandle = json["person"]?["twitterid"] as? String
        self.imageURL = json["image"] as? String
        self.fullTitle = json["name"] as? String
        
        if let fullTitle = fullTitle {
            let tuple = parseNameJsonField(json: fullTitle)
            if self.district == nil {
                self.district = tuple.district
            }
            if self.party == nil {
                self.party = tuple.party
            }
            if self.representativeType == nil {
                self.representativeType = tuple.repType
            }
            if self.firstName == nil {
                self.firstName = tuple.first
            }
            if self.lastName == nil {
                self.lastName = tuple.last
            }
        }
    }
    
    func toLightRepresentative() -> LightRepresentative {
        var lightRep = LightRepresentative()
        lightRep.firstName = self.firstName
        lightRep.lastName = self.lastName
        lightRep.district = self.district
        lightRep.imageURL = self.imageURL
        lightRep.party = self.party
        lightRep.representativeType = self.representativeType
        return lightRep
    }
}

struct LightRepresentative: Representative {
    
    var firstName: String?
    var lastName: String?
    var id: Int?
    var fullTitle: String?
    var imageURL: String?
    var district: Int?
    var state: String?
    var party: Party?
    var representativeType: RepresentativeType?

    init(from json: [String: AnyObject]) {
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        self.id = json["id"] as? Int
        self.imageURL = json["image"] as? String
        self.fullTitle = json["name"] as? String
        
        if let fullTitle = fullTitle {
            let tuple = parseNameJsonField(json: fullTitle)
            self.district = tuple.district
            self.party = tuple.party
            self.representativeType = tuple.repType
            if self.firstName == nil {
                self.firstName = tuple.first
            }
            if self.lastName == nil {
                self.lastName = tuple.last
            }
        }
    }
    
    init() {}
}
