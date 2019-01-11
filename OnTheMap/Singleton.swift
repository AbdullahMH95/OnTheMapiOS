//
//  Singleton.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 06/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class Singleton {
    
    static let shared = Singleton()
    
    var sessionID: String? = ""
    var userKey = ""
    var firstName = ""
    var lastName = ""
    
    var locations: [Location]? = nil
    
    private init() {}
}
