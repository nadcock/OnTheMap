//
//  Udacity.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/24/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import MapKit

class StudentData {
    var login: String?
    var firstName: String?
    var lastName: String?
    var key: String?
    var locations: [StudentInformation]?
    var annotations: [MKPointAnnotation]?
    
    static let sharedInstance = StudentData()
}