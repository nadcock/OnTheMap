//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/23/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation

// MARK: Constants
struct UdacityConstants {
    
    struct Udacity {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "/session"
        static let Users = "/users"
        
    }
    
    // MARK: TMDB Parameter Keys
    struct UdacityParameterKeys {
        static let ApiKey = "api_key"
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: TMDB Parameter Values
    struct UdacityParameterValues {
        static let ApiKey = ""
    }
    
    func buildSessionURL() -> String {
        return "\(Udacity.ApiScheme)://\(Udacity.ApiHost)\(Udacity.ApiPath)\(Methods.Session)"
    }
    
    func buildUsersURL() -> String {
        return "\(Udacity.ApiScheme)://\(Udacity.ApiHost)\(Udacity.ApiPath)\(Methods.Users)"
    }
    
}