//
//  UserDefaults+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 09/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public extension UserDefaults {
 
    public enum UserDefaultsKey: String {
        
        case defaultETHAddressID = "DEFAULT_ETH_ADDRESS_KEY"
    }
    
    func storeDelfaultETHAddressID(ethAddressID: String?) {
        UserDefaults.standard.set(ethAddressID, forKey: UserDefaultsKey.defaultETHAddressID.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func loadDelfaultETHAddressID() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKey.defaultETHAddressID.rawValue)
    }
}
