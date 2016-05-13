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
    
    var user: StudentInforamion?
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
        updateMap()
    }
    
    
    @IBAction func logoutTapped(sender: AnyObject) {
        parse.logout(){
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.spinner.startAnimating()
        mapView.removeAnnotations(self.user!.annotations!)
        updateMap()
    }
    
    func updateMap() {
        parse.getStudentLocations() { locations, annotations -> Void in
            
            self.user!.locations = locations
            self.user!.annotations = annotations
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(self.user!.annotations!)
                self.spinner.stopAnimating()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toInfoPostingSegue" {
            let nextScene =  segue.destinationViewController as! InformationPostingViewController
            nextScene.user = user
        }
    }
}

extension MapViewController {
    
    func displayAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
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