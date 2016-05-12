//
//  Parse.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/24/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Parse: NSObject {
    var locations = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
    
    override init() {
        super.init()
    }
    
    func removeAllAnnotations() {
        locations = []
        annotations = []
    }
    
    func getStudentLocations(completionHandler handler: (Void) -> Void) {
        removeAllAnnotations()
        let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.ParseURL.BaseURL)!)
        request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
        request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print(error)
                return
            }
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse datas JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                return
            }
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                self.locations = StudentInformation.locationsFromResults(results)
                self.setAnnotations(completionHandler: handler)
            }
            
        }
        task.resume()
    }
    
    func setAnnotations(completionHandler handler: (Void) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            self.annotations = StudentInformation.annotaionsFromLocations(self.locations)
    
            handler()
        }
    }
    
    func logout(completionHandler handler: (Void) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                //self.displayAlert("Could not parse JSON data")
                return
            }
            
            print("parsed result of logout: \(parsedResult)")
            handler()
    
        }
        task.resume()
    }
}


struct ParseConstants {
    struct ParseURL {
        static let BaseURL = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct MethodsKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        struct Order {
            static let baseMethod = "order"
        }
    }
    
    struct ParseResponseKeys {
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    struct Keys {
        static let ApplicationID = "X-Parse-Application-Id"
        static let RestAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct Values {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
}