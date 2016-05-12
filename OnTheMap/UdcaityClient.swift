//
//  UdcaityClient.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/23/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    var sessionID = ""
    
    func authenticateUser(username: String, password: String) -> Void {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func getSession(username: String, password: String
}