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

    static func getStudentLocations(errorHandler: (Void) -> Void, completionHandler handler: ([StudentInformation], [MKPointAnnotation]) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(ParseConstants.ParseURL.BaseURL)?\(ParseConstants.MethodsKeys.Order.baseMethod)=\(ParseConstants.MethodsKeys.Order.option)&\(ParseConstants.MethodsKeys.Limit)=100")!)
        request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
        request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                self.displayAlert((error?.localizedDescription)!, completionHandler: errorHandler)
                print(error)
                return
            }
            guard let data = data else {
                self.displayAlert("There was an error with your request", completionHandler: errorHandler)
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse data's JSON", completionHandler: errorHandler)
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                self.displayAlert("Could not find \"results\" in parsedResults", completionHandler: errorHandler)
                print("Results: \(parsedResult)")
                return
            }
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                let locations = StudentInformation.locationsFromResults(results)
                self.setAnnotations(locations, completionHandler: handler)
            }
            
        }
        task.resume()
    }
    
    static func setAnnotations(locations: [StudentInformation], completionHandler handler: ([StudentInformation], [MKPointAnnotation]) -> Void ) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            let annotations = StudentInformation.annotaionsFromLocations(locations)
    
            handler(locations, annotations)
        }
    }
    
    static func logout(errorHandler: (Void) -> Void, completionHandler handler: (Void) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityConstants.buildSessionURL())!)
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
                self.displayAlert((error?.localizedDescription)!, completionHandler: errorHandler)
                return
            }
            
            guard let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */ else {
                self.displayAlert("There was an error with your request", completionHandler: errorHandler)
                return
            }
            
            
            let _: AnyObject!
            do {
                _ = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse JSON data", completionHandler: errorHandler)
                return
            }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                handler()
            }
    
        }
        task.resume()
    }
    
    static func postLocation(params: [String:AnyObject], errorHandler: (Void) -> Void, completionHandler handler: Void -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.ParseURL.BaseURL)!)
        request.HTTPMethod = "POST"
        request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
        request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            self.displayAlert("There was an error Serializing the JSON data", completionHandler: errorHandler)
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                self.displayAlert("There was an error with your request", completionHandler: errorHandler)
                return
            }
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            handler()
        }
        
        task.resume()

    }
    
    static func displayAlert(alertMessage: String, completionHandler handler: (Void) -> Void) {
        performUIUpdatesOnMain {
            let alertController = DBAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {
                (action) in handler()
                })
            alertController.show()
        }
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
            static let option = "-updatedAt"
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
    //QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY
    struct Values {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
}