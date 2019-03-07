//
//  ConstantsSwift.swift
//  SDOSEnvironmentExample
//
//  Created by Rafael Fernandez Alvarez on 06/03/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

@objc class ConstantsSwift: NSObject {
    @objc static func getWSBaseUrl() -> String {
        return Environment.wsBaseUrl
    }
    
    @objc static func getEnvironmentDescription() -> String {
        return Environment.environmentDescription
    }
    
    @objc static func getGoogleAnalyticsKey() -> String {
        return Environment.googleAnalyticsKey
    }
    
    @objc static func getOctopushMode() -> String {
        return Environment.octopushMode
    }
    
    @objc static func getShowSelectedEnvironmentsOnLoad() -> String {
        return Environment.showSelectedEnvironmentsOnLoad
    }
}
