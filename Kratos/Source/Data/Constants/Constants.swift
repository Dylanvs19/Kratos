//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum Constant: String {
    
    //ExploreVC
    case exploreTitle = "On The Floor"
    case exploreSenateButtonTitle = "Senate"
    case exploreHouseButtonTitle = "House"
    
    //RepInfoView
    case repInfoViewBioTitle = "Biography"
    case repInfoViewVotesTitle = "Votes"
    case repInfoViewBillsTitle = "Sponsored Bills"
    case repInfoViewTermsSectionTitle = "Terms"
    
    //ExpandableTextFieldView
    case expandableTextFieldViewExpandedButtonTitle = "Show Less"
    case expandableTextFieldViewContractedButtonTitle = "Show More"
}

func localize(_ constant: Constant) -> String {
    return constant.rawValue
}
