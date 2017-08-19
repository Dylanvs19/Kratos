//
//  State.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/17/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

enum State: String, RawRepresentable {
    case alabama = "AL"
    case alaska = "AK"
    case arizona = "AZ"
    case arkansas = "AR"
    case california = "CA"
    case colorado = "CO"
    case connecticut = "CT"
    case washingtonDC = "DC"
    case delaware = "DE"
    case florida = "FL"
    case georgia = "GA"
    case hawaii = "HI"
    case idaho = "ID"
    case illinois = "IL"
    case indiana = "IN"
    case iowa = "IA"
    case kansas = "KS"
    case kentucky = "KY"
    case louisiana = "LA"
    case maine = "ME"
    case maryland = "MD"
    case massachusets = "MA"
    case michigan = "MI"
    case minnesota =  "MN"
    case mississippi = "MS"
    case missouri = "MO"
    case montana = "MT"
    case nebraska = "NE"
    case nevada = "NV"
    case newHampshire = "NH"
    case newJersey = "NJ"
    case newMexico = "NM"
    case newYork = "NY"
    case northCarolina = "NC"
    case northDakota = "ND"
    case ohio = "OH"
    case oklahoma = "OK"
    case oregon = "OR"
    case pennsylvania = "PA"
    case puertoRico = "PR"
    case rhodeIsland = "RI"
    case southCarolina = "SC"
    case southDakota = "SD"
    case tennessee = "TN"
    case texas = "TX"
    case utah = "UT"
    case vermont = "VT"
    case virginia = "VA"
    case washington = "WA"
    case westVirginia = "WV"
    case wisconsin = "WI"
    case wyoming = "WY"
    
    var fullName: String {
        switch self {
        case .alabama:
            return "Alabama"
        case .alaska:
            return "Alaska"
        case .arizona:
            return "Arizona"
        case .arkansas:
            return "Arkansas"
        case .california:
            return "California"
        case .colorado:
            return "Colorado"
        case .connecticut:
            return "Conneticut"
        case .washingtonDC:
            return "Washington D.C."
        case .delaware:
            return "Delaware"
        case .florida:
            return "Florida"
        case .georgia:
            return "Georgia"
        case .hawaii:
            return "Hawaii"
        case .idaho:
            return "Idaho"
        case .illinois:
            return "Illinois"
        case .indiana:
            return "Indiana"
        case .iowa:
            return "Iowa"
        case .kansas:
            return "Kansas"
        case .kentucky:
            return "Kentucky"
        case .louisiana:
            return "Louisiana"
        case .maine:
            return "Maine"
        case .maryland:
            return "Maryland"
        case .massachusets:
            return "Massachusets"
        case .michigan:
            return "Michigan"
        case .minnesota:
            return "Minnesota"
        case .mississippi:
            return "Mississippi"
        case .missouri:
            return "Missouri"
        case .montana:
            return "Montana"
        case .nebraska:
            return "Nebraska"
        case .nevada:
            return "Nevada"
        case .newHampshire:
            return "New Hampshire"
        case .newJersey:
            return "New Jersey"
        case .newMexico:
            return "New Mexico"
        case .newYork:
            return "New York"
        case .northCarolina:
            return "North Carolina"
        case .northDakota:
            return "North Dakota"
        case .ohio:
            return "Ohio"
        case .oklahoma:
            return "Oklahoma"
        case .oregon:
            return "Oregon"
        case .pennsylvania:
            return "Pennsylvania"
        case .puertoRico:
            return "Puerto Rico"
        case .rhodeIsland:
            return "Rhode Island"
        case .southCarolina:
            return "South Carolina"
        case .southDakota:
            return "South Dakota"
        case .tennessee:
            return "Tennessee"
        case .texas:
            return "Texas"
        case .utah:
            return "Utah"
        case .vermont:
            return "Vermont"
        case .virginia:
            return "Virginia"
        case .washington:
            return "Washington"
        case .westVirginia:
            return "West Virginia"
        case .wisconsin:
            return "Wisconsin"
        case .wyoming:
            return "Wyoming"
        }
    }
    
    var whiteImage: UIImage {
        switch self {
        case .alabama:
            return #imageLiteral(resourceName: "alabamaWhite")
        case .alaska:
            return #imageLiteral(resourceName: "alaskaWhite")
        case .arizona:
            return #imageLiteral(resourceName: "arizonaWhite")
        case .arkansas:
            return #imageLiteral(resourceName: "arkansasWhite")
        case .california:
            return #imageLiteral(resourceName: "californiaWhite")
        case .colorado:
            return #imageLiteral(resourceName: "coloradoWhite")
        case .connecticut:
            return #imageLiteral(resourceName: "conneticutWhite")
        case .washingtonDC:
            return #imageLiteral(resourceName: "washingtonDCWhite")
        case .delaware:
            return #imageLiteral(resourceName: "delawareWhite")
        case .florida:
            return #imageLiteral(resourceName: "floridaWhite")
        case .georgia:
            return #imageLiteral(resourceName: "georgiaWhite")
        case .hawaii:
            return #imageLiteral(resourceName: "hawaiiWhite")
        case .idaho:
            return #imageLiteral(resourceName: "idahoWhite")
        case .illinois:
            return #imageLiteral(resourceName: "illinoisWhite")
        case .indiana:
            return #imageLiteral(resourceName: "indianaWhite")
        case .iowa:
            return #imageLiteral(resourceName: "iowaWhite")
        case .kansas:
            return #imageLiteral(resourceName: "kansasWhite")
        case .kentucky:
            return #imageLiteral(resourceName: "kentuckyWhite")
        case .louisiana:
            return #imageLiteral(resourceName: "louisianaWhite")
        case .maine:
            return #imageLiteral(resourceName: "maineWhite")
        case .maryland:
            return #imageLiteral(resourceName: "marylandWhite")
        case .massachusets:
            return #imageLiteral(resourceName: "massachusetsWhite")
        case .michigan:
            return #imageLiteral(resourceName: "michiganWhite")
        case .minnesota:
            return #imageLiteral(resourceName: "minnesotaWhite")
        case .mississippi:
            return #imageLiteral(resourceName: "mississippiWhite")
        case .missouri:
            return #imageLiteral(resourceName: "missouriWhite")
        case .montana:
            return #imageLiteral(resourceName: "montanaWhite")
        case .nebraska:
            return #imageLiteral(resourceName: "nebraskaWhite")
        case .nevada:
            return #imageLiteral(resourceName: "nevadaWhite")
        case .newHampshire:
            return #imageLiteral(resourceName: "newHampshireWhite")
        case .newJersey:
            return #imageLiteral(resourceName: "newJerseyWhite")
        case .newMexico:
            return #imageLiteral(resourceName: "newMexicoWhite")
        case .newYork:
            return #imageLiteral(resourceName: "newYorkWhite")
        case .northCarolina:
            return #imageLiteral(resourceName: "northCarolinaWhite")
        case .northDakota:
            return #imageLiteral(resourceName: "northDakotaWhite")
        case .ohio:
            return #imageLiteral(resourceName: "ohioWhite")
        case .oklahoma:
            return #imageLiteral(resourceName: "oklahomaWhite")
        case .oregon:
            return #imageLiteral(resourceName: "oregonWhite")
        case .pennsylvania:
            return #imageLiteral(resourceName: "pennsylvaniaWhite")
        case .puertoRico:
            return #imageLiteral(resourceName: "puertoRicoWhite")
        case .rhodeIsland:
            return #imageLiteral(resourceName: "rhodeIslandWhite")
        case .southCarolina:
            return #imageLiteral(resourceName: "southCarolinaWhite")
        case .southDakota:
            return #imageLiteral(resourceName: "southDakotaWhite")
        case .tennessee:
            return #imageLiteral(resourceName: "tennesseeWhite")
        case .texas:
            return #imageLiteral(resourceName: "texasWhite")
        case .utah:
            return #imageLiteral(resourceName: "utahWhite")
        case .vermont:
            return #imageLiteral(resourceName: "vermontWhite")
        case .virginia:
            return #imageLiteral(resourceName: "virginiaWhite")
        case .washington:
            return #imageLiteral(resourceName: "washintonWhite")
        case .westVirginia:
            return #imageLiteral(resourceName: "westVirginiaWhite")
        case .wisconsin:
            return #imageLiteral(resourceName: "wisconsinWhite")
        case .wyoming:
            return #imageLiteral(resourceName: "wyomingWhite")
        }
    }
}
