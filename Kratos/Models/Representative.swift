//
//  Representative.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

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

struct LightRepresentative {
    
    var firstName: String?
    var lastName: String?
    var id: Int?
    var imageURL: String?
    var state: String?
    var party: Party?
    var representativeType: RepresentativeType?
    var district: Int? 

    init(from json: [String: AnyObject]) {
        self.firstName = json["firstname"] as? String
        self.lastName = json["lastname"] as? String
        self.id = json["id"] as? Int
        self.imageURL = json["person_image"] as? String
    }
    
    init() {}
}
