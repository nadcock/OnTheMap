//
//  UdacityConvience.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/23/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit

class Udacity {
    let uconst = UdacityConstants()
    
    func getSession(username: String, password: String, errorHandler: Void -> Void, completionHandler handler: (String, String, String, String) -> Void) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: uconst.buildSessionURL())!)
        print("\(uconst.buildSessionURL())")
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"\(UdacityConstants.UdacityParameterKeys.Username)\": \"\(username)\", \"\(UdacityConstants.UdacityParameterKeys.Password)\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                self.displayAlert((error?.localizedDescription)!, completionHandler: errorHandler)
                print(error)
            }
            
            
            guard let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */ else {
                self.displayAlert("There was an error with your request", completionHandler: errorHandler)
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse datas JSON", completionHandler: errorHandler)
                return
            }
            
            guard let results = parsedResult["account"] as? [String:AnyObject] else {
                let error = parsedResult["error"] as! String
                self.displayAlert(error, completionHandler: errorHandler)
                return
                
            }
            
            guard let key = results["key"] as? String else {
                self.displayAlert("Could not find \"key\" in results", completionHandler: errorHandler)
                return
            }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                self.getUserData(key, username: username, errorHandler: errorHandler, completionHandler: handler)
            }
            
            
            //self.completeLogin()
        }
        task.resume()
    }
    
    func getUserData(key: String, username: String, errorHandler: Void -> Void, completionHandler handler: (String, String, String, String) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(uconst.buildUsersURL())/\(key)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                self.displayAlert((error?.localizedDescription)!, completionHandler: errorHandler)
                return
            }
            guard let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */ else {
                self.displayAlert("There was an error with your request", completionHandler: errorHandler)
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                self.displayAlert("Could not parse data's JSON", completionHandler: errorHandler)
                return
            }
            
            guard let results = parsedResult["user"] as? [String:AnyObject] else {
                self.displayAlert("Could not find \"user\" in results", completionHandler: errorHandler)
                print("Results: \(parsedResult)")
                return
            }
            
            guard let lastName = results["last_name"] as? String else {
                self.displayAlert("Could not find \"last_name\" in results", completionHandler: errorHandler)
                print("Results: \(parsedResult)")
                return
            }
            guard let firstName = results["first_name"] as? String else {
                self.displayAlert("Could not find \"first_name\" in results", completionHandler: errorHandler)
                print("Results: \(parsedResult)")
                return
            }

            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                handler(key, firstName, lastName, username)
            }
            
            
        }
        task.resume()
    }

    func displayAlert(alertMessage: String, completionHandler handler: (Void) -> Void) {
        performUIUpdatesOnMain {
            let alertController = DBAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {
                (action) in handler()
            })
            alertController.show()
        }
    }
}

enum NetworkRequestError: ErrorType {
    case InvalidJSON(message: String)
    case InvalidKey(message: String)
    case RequestError(message: String)
}