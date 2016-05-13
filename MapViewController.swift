//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/24/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let parse = Parse()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutBarButton: UIBarButtonItem!
    @IBOutlet weak var pinBarButton: UIBarButtonItem!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        updateMap()
    }
    
    
    @IBAction func logoutTapped(sender: AnyObject) {
        parse.logout({}){
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.spinner.startAnimating()
        if let annotations = StudentData.annotations {
            self.mapView.removeAnnotations((annotations))
        }
        updateMap()
    }
    
    
    func updateMap() {
        parse.getStudentLocations(errorCompletionHandler) { locations, annotations -> Void in
            
            StudentData.locations = locations
            StudentData.annotations = annotations
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(StudentData.annotations!)
                self.spinner.stopAnimating()
            }
        }
    }
    
    func errorCompletionHandler() {
        spinner.stopAnimating()
    }
    
}

extension MapViewController {
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }

}