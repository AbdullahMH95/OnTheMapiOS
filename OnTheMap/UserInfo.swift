//
//  UserInfo.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 06/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct UserSession: Codable {
    let account: Account?
    let session: Session?
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct Location: Codable {
    let objectId: String?
    let mediaURL: String?
    let firstName: String?
    let longitude: Double?
    let uniqueKey: String?
    let latitude: Double?
    let mapString: String?
    let lastName: String?
    let createdAt: String?
    let updatedAt: String?
    
    init(mediaURL: String?, firstName: String?, lastName: String?, latitude: Double?, mapString: String?, longitude: Double?) {
        self.mapString = mapString!
        self.firstName = firstName!
        self.lastName = lastName!
        self.latitude = latitude!
        self.longitude = longitude!
        self.mediaURL = mediaURL!
        self.updatedAt = ""
        self.createdAt = ""
        self.uniqueKey = ""
        self.objectId = ""
    }
    
}

struct Result: Codable {
    let results: [Location]?
    
    private enum CodingKeys : String, CodingKey {
        case results = "results"
    }
}
