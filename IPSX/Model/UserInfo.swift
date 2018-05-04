//
//  UserInfo.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct UserInfo {
    
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var telegram: String?
    var countryID: String?
    var email: String?
    var proxyTest: String?
    
    init(firstName: String? = nil, middleName: String? = nil,lastName: String? = nil,
         telegram: String? = nil, countryID: String? = nil, email: String? = nil, proxyTest: String? = nil) {
        
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.telegram = telegram
        self.countryID = countryID
        self.email = email
        self.proxyTest = proxyTest
    }
}
