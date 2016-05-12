//
//  Location.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/24/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    let objectID: String
    let uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[ParseConstants.ParseResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseConstants.ParseResponseKeys.UniqueKey] as? String
        firstName = dictionary[ParseConstants.ParseResponseKeys.FirstName] as! String
        lastName = dictionary[ParseConstants.ParseResponseKeys.LastName] as! String
        mapString = dictionary[ParseConstants.ParseResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseConstants.ParseResponseKeys.MediaURL] as! String
        latitude = dictionary[ParseConstants.ParseResponseKeys.Latitude] as! Float
        longitude = dictionary[ParseConstants.ParseResponseKeys.Longitude] as! Float
    }
    
    static func locationsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        var locations = [StudentInformation]()
        
        for result in results {
            locations.append(StudentInformation(dictionary: result))
        }
        
        return locations
    }
    
    static func annotaionsFromLocations(locations: [StudentInformation]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        return annotations
    }
    
        
}