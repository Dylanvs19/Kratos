//
//  Contstants.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation

enum Constant {
    
    // ExploreVC
    case exploreTitle
    case exploreSenateButtonTitle
    case exploreHouseButtonTitle
    
    //InfoView
    case infoViewVotesTitle
    
    // RepInfoView
    case repInfoViewBioTitle
    case repInfoViewVotesTitle
    case repInfoViewBillsTitle
    case repInfoViewTermsSectionTitle
    
    // BillInfoView
    case billInfoViewSummaryTitle
    case billInfoViewVotesTitle
    case billInfoViewSponsorsTitle
    case billInfoViewDetailsTitle
    
    // ExpandableTextFieldView
    case expandableTextFieldViewExpandedButtonTitle
    case expandableTextFieldViewContractedButtonTitle
    
    var string: String {
        switch self {
        case .exploreTitle: return  "On The Floor"
        case .exploreSenateButtonTitle: return "Senate"
        case .exploreHouseButtonTitle: return "House"
            
        //InfoView
        case .infoViewVotesTitle: return "Votes"
            
        // RepInfoView
        case .repInfoViewBioTitle: return "Biography"
        case .repInfoViewVotesTitle: return "Votes"
        case .repInfoViewBillsTitle: return "Sponsored Bills"
        case .repInfoViewTermsSectionTitle: return "Terms"
            
        // BillInfoView
        case .billInfoViewSummaryTitle: return  "Summary"
        case .billInfoViewVotesTitle: return "Votes"
        case .billInfoViewSponsorsTitle: return "Sponsors"
        case .billInfoViewDetailsTitle: return "Details"
            
        // ExpandableTextFieldView
        case .expandableTextFieldViewExpandedButtonTitle: return "Show Less"
        case .expandableTextFieldViewContractedButtonTitle: return "Show More"
        }
    }
}

func localize(_ constant: Constant) -> String {
    return constant.string
}
