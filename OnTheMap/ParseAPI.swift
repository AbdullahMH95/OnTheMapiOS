//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 14/12/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class ParseAPI {
    
    static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static func login(email: String, password: String,
                      onComplete: @escaping (_ error: String?, _ done: Bool, _ userKey: String?) -> Void) {
        
        let url = URL(string: "https://onthemap-api.udacity.com/v1/session")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonDictionary =
            [
                "udacity" : [ "username" : email, "password": password]
                ]
                as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary)
        
        print("JsonDtata!!!")
        print(jsonData)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                onComplete(error?.localizedDescription, false, nil)
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    onComplete("Status code is: \(httpResponse.statusCode)", false, nil)
                    return
                }
            }
            print(response!)
            print("After update!!!-")
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            
            print(String(data: newData!, encoding: .utf8)!)
            
            let responseDict = try! JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! NSDictionary
            
            if responseDict["account"] != nil && responseDict["session"] != nil {
                let decoder = JSONDecoder()
                do {
                    let decoded = try decoder.decode(UserSession.self, from: newData!)
                    print(decoded.account!)
                    print(decoded.session!)
                    Singleton.shared.sessionID = decoded.session!.id
                    Singleton.shared.userKey = decoded.account!.key
                    onComplete(nil, true, decoded.account!.key)
                } catch {
                    print("Failed to decode JSON")
                }
                return
            } else if responseDict["status"] != nil {
                let status = responseDict["status"] as! Int
                if status == 403 || status == 400 {
                    onComplete("Status is 400 or 403", false, nil)
                    return
                }
            } else {
                onComplete("Error, try again", false, nil)
            }
        }
        task.resume()
    }
    
    static func GETtingStudentLocations(userKay: String?,  onComplete: @escaping (_ error: String?, _ done: Bool, _ data: [Location]?) -> Void
        ) {
        print(userKay!)
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                onComplete(error.debugDescription , false, nil)
                return
            }
            print("Response for locarion")
            print(String(data: data!, encoding: .utf8)!)
            do {
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(Result.self, from: data!)
                print("Now we get some locations?")
                print(gitData.results!.count)
                Singleton.shared.locations = gitData.results!
                onComplete(nil, true, gitData.results!)
                
                
            } catch let err {
                onComplete(err.localizedDescription, false, nil)
            }
        }
        task.resume()
    }
    
    static func logout(onComplete: @escaping (_ error: String?, _ done: Bool) -> Void
        ) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                onComplete(error.debugDescription, false)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            onComplete(nil, true)
        }
        task.resume()
    }
    
    static func POSTingStudentLocation(mapString: String, mediaURL: String, lat: Double, long: Double, onComplete: @escaping (_ error: String?, _ done: Bool) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue(parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDictionary = [
            "uniqueKey": Singleton.shared.userKey as Any,
            "firstName": Singleton.shared.firstName as Any,
            "lastName": Singleton.shared.lastName as Any,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": lat,
            "longitude": long
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary)
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                onComplete(error.debugDescription, false)
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            onComplete(nil, true)
        }
        task.resume()
    }
    
    static func GETtingPublicUserData(userKey: String?, onComplete: @escaping (_ error: String?,_ done: Bool) -> Void ){
        
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(userKey!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                onComplete(error.debugDescription, false)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print("UserData: ", String(data: newData!, encoding: .utf8)!)
            let json = try? JSONSerialization.jsonObject(with: newData!, options: [])
            if let dictionary = json as? [String: Any] {
                if let firstName = dictionary["first_name"] as? String {
                    print("FirstName: ", firstName)
                    Singleton.shared.firstName = firstName
                } else {
                    Singleton.shared.firstName = "No first name"
                    
                }
                if let lastName = dictionary["last_name"] as? String {
                    Singleton.shared.lastName = lastName
                    print("LastName: ", lastName)
                } else {
                    Singleton.shared.lastName = "No Last name"
                }
                
                onComplete(nil, true)
            }
            
            
        }
        task.resume()
    }
    
    static func GETtingStudentLocation( onComplete: @escaping (_ error: String?, _ done: Bool, _ data: Location?) -> Void
        ) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(Singleton.shared.userKey)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print("Single location?: " ,String(data: data!, encoding: .utf8)!)
            do {
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(Result.self, from: data!)
                print("Now we get some locations?")
                print(gitData.results!.count)
                if gitData.results!.count == 0 {
                    onComplete("count is 0", false, nil)
                    return
                } else {
                onComplete(nil, true, gitData.results?.first)
                }
                
            } catch let err {
                onComplete(err.localizedDescription, false, nil)
            }
        }
        task.resume()
    }
    
}
