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

    func getStudentLocations(completionHandler handler: ([Location], [MKPointAnnotation]) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.ParseURL.BaseURL)!)
        request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
        request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                self.displayAlert("There was an error with your request")
                print(error)
                return
            }
            guard let data = data else {
                self.displayAlert("There was an error with your request")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse data's JSON")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                self.displayAlert("Could not find \"results\" in parsedResults")
                print("Results: \(parsedResult)")
                return
            }
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                let locations = Location.locationsFromResults(results)
                self.setAnnotations(locations, completionHandler: handler)
            }
            
        }
        task.resume()
    }
    
    func setAnnotations(locations: [Location], completionHandler handler: ([Location], [MKPointAnnotation]) -> Void ) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            let annotations = Location.annotaionsFromLocations(locations)
    
            handler(locations, annotations)
        }
    }
    
    func logout(completionHandler handler: (Void) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityConstants().buildSessionURL())!)
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
                self.displayAlert("There was an error with your request")
                return
            }
            
            guard let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */ else {
                self.displayAlert("There was an error with your request")
                return
            }
            
            
            let _: AnyObject!
            do {
                _ = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse JSON data")
                return
            }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                handler()
            }
    
        }
        task.resume()
    }
    
    func postLocation(params: [String:AnyObject], completionHandler handler: Void -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.ParseURL.BaseURL)!)
        request.HTTPMethod = "POST"
        request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
        request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            self.displayAlert("There was an error Serializing the JSON data")
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                self.displayAlert("There was an error with your request")
                return
            }
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            handler()
        }
        
        task.resume()

    }
    
    func displayAlert(alertMessage: String) {
        performUIUpdatesOnMain {
            let alertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
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