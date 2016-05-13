//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Nick Adcock on 5/11/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate  {
    
    let parse = Parse()
    
    let udacityBlue = UIColor(red: 22/220, green: 164/220, blue: 1.0, alpha: 1.0)
    let padding = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    var userLocation: MKAnnotation?
    
    @IBOutlet var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topLabel: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locaitonTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        locaitonTextField.delegate = self
        urlTextField.delegate = self
        spinner.hidesWhenStopped = true
        setInitalUI()
    }
    
    @IBAction func switchTapped(sender: UIButton) {
        if sender.titleLabel!.text == "Find on the Map" {
        
            self.spinner.startAnimating()

            if locaitonTextField.text == "" {
                let alert = UIAlertController(title: "Empty Location", message: "Please enter a valid location", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let geoString = locaitonTextField.text!
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(geoString, completionHandler: { placemarks, error -> Void in
                if error != nil {
                    
                }
                
                if let placemark = placemarks?.first {
                    self.userLocation = MKPlacemark(placemark: placemark) as MKAnnotation
                    self.mapView.addAnnotation(self.userLocation!)

                    let span = MKCoordinateSpanMake(0.5, 0.5)
                    let region = MKCoordinateRegion(center: self.userLocation!.coordinate, span: span)
                    self.mapView.setRegion(region, animated: false)
                    
                    self.spinner.stopAnimating()
                    self.switchUI()
                } else {
                    print(error!)
                    let alert = UIAlertController(title: "Ooops...", message: "It looks like we could not find that location! Please try a different location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.spinner.stopAnimating()
                    self.setInitalUI()
                    return
                }
            })
            
        } else {
            let params = [
                "uniqueKey" : StudentData.key!,
                "firstName" : StudentData.firstName!,
                "lastName"  : StudentData.lastName!,
                "mapString" : self.locaitonTextField.text!,
                "mediaURL"  : self.urlTextField.text!,
                "latitude"  : userLocation!.coordinate.latitude,
                "longitude" : userLocation!.coordinate.longitude
            ]
            self.spinner.startAnimating()
            parse.postLocation(params as! [String : AnyObject], errorHandler: errorCompletionHandler) {
                performUIUpdatesOnMain {
                    self.spinner.stopAnimating()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func errorCompletionHandler() {
        spinner.stopAnimating()
    }
    
    @IBAction func textFieldBeganEditing(sender: UITextField) {
        sender.placeholder = nil
    }
    
    
    func setInitalUI () {
        topView.backgroundColor = UIColor.whiteColor()
        bottomView.backgroundColor = udacityBlue
        mapView.hidden = true
        setTextFieldUI("e.g.: San Francisco, CA", textField: locaitonTextField)
        
        cancelButton.titleLabel!.textColor = udacityBlue
        topLabel.hidden = false
        urlTextField.hidden = true
        
        submitButton.backgroundColor = UIColor.whiteColor()
        submitButton.titleLabel!.textColor = udacityBlue
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = udacityBlue.CGColor
        submitButton.contentEdgeInsets = padding
        submitButton.setTitle("Find on the Map", forState: .Normal)
    }
    
    func switchUI () {
        locaitonTextField.hidden = true
        urlTextField.hidden = false
        
        setTextFieldUI("Enter ULR: www.example.com", textField: urlTextField)
        topView.backgroundColor = udacityBlue
        cancelButton.titleLabel!.textColor = UIColor.whiteColor()
        
        topLabel.hidden = true
        bottomView.backgroundColor = UIColor.whiteColor()
        mapView.hidden = false
        bottomBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        submitButton.setTitle("Submit", forState: .Normal)
    }
    
    func setTextFieldUI (placeHolderText: String, textField: UITextField){
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText,
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
        textField.hidden = false
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension InformationPostingViewController {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

}