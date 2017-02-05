//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

struct Constants {
    
    static let REGISTRATION_URL = "https://kratos.website/api/registrations"
    static let LOGIN_URL = "https://kratos.website/api/login"
    static let USER_URL = "https://kratos.website/api/me"
    static let FORGOT_PASSWORD_URL = "https://kratos.website/api/forgot-password"
    static let FEEDBACK_URL = "https://kratos.website/api/feedback"
    
    static let REPRESENTATIVES_URL = "https://kratos.website/api/districts/"
    static let PERSON_URL = "https://kratos.website/api/people/"
    static let VOTES_URL = "https://kratos.website/api/people/"
    static let TALLY_URL = "https://kratos.website/api/tallies/"
    static let BILL_URL = "https://kratos.website/api/bills/"
    
    static let YOUR_VOTES_URL = "https://kratos.website/api/me/votes"
    static let YOUR_VOTES_CREATE_URL = "https://kratos.website/api/me/votes"
    static let YOUR_VOTES_INDIVIDUAL_VOTE_URL = "https://kratos.website/api/me/votes/"
    
    static let YOUR_ACTION_URL = "https://kratos.website/api/me/actions"
    
    static let statePictureDict =  [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DC": "WashingtonDC",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachuse",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "NewHampshire",
        "NJ": "NewJersey",
        "NM": "NewMexico",
        "NY": "NewYork",
        "NC": "NorthCarolina",
        "ND": "NorthDakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "PR": "PuertoRico",
        "RI": "RhodeIsland",
        "SC": "SouthCarolina",
        "SD": "SouthDakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "WestVirginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
    static let abbreviationToFullStateNameDict =  [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DC": "Washington D.C.",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachuse",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "PR": "Puerto Rico",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
    static let stateSet = Set([
        "AL",
        "AK",
        "AS",
        "AZ",
        "AR",
        "CA",
        "CO",
        "CT",
        "DE",
        "DC",
        "FM",
        "FL",
        "GA",
        "GU",
        "HI",
        "ID",
        "IL",
        "IN",
        "IA",
        "KS",
        "KY",
        "LA",
        "ME",
        "MH",
        "MD",
        "MA",
        "MI",
        "MN",
        "MS",
        "MO",
        "MT",
        "NE",
        "NV",
        "NH",
        "NJ",
        "NM",
        "NY",
        "NC",
        "ND",
        "MP",
        "OH",
        "OK",
        "OR",
        "PW",
        "PA",
        "PR",
        "RI",
        "SC",
        "SD",
        "TN",
        "TX",
        "UT",
        "VT",
        "VI",
        "VA",
        "WA",
        "WV",
        "WI",
        "WY",
        ])
}
