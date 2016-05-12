//
//  AsyncMethods.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/24/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}