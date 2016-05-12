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
    
    let udacityBlue = UIColor(red: 22/220, green: 164/220, blue: 1.0, alpha: 1.0)
    let padding = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                    
                    // optionally you can set your own boundaries of the zoom
                    let span = MKCoordinateSpanMake(0.5, 0.5)
                    
                    // or use the current map zoom and just center the map
                    // let span = mapView.region.span
                    
                    // now move the map
                    let region = MKCoordinateRegion(center: self.userLocation!.coordinate, span: span)
                    self.mapView.setRegion(region, animated: false)
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
            self.spinner.stopAnimating()
            switchUI()
        } else {
            let params = [
                "uniqueKey" : self.appDelegate.userInfo.key!,
                "firstName" : self.appDelegate.userInfo.firstName!,
                "lastName"  : self.appDelegate.userInfo.lastName!,
                "mapString" : self.locaitonTextField.text!,
                "mediaURL"  : self.urlTextField.text!,
                "latitude"  : userLocation!.coordinate.latitude,
                "longitude" : userLocation!.coordinate.longitude
            ]
            self.spinner.startAnimating()
            
            let request = NSMutableURLRequest(URL: NSURL(string: ParseConstants.ParseURL.BaseURL)!)
            request.HTTPMethod = "POST"
            request.addValue(ParseConstants.Values.ApplicationID, forHTTPHeaderField: ParseConstants.Keys.ApplicationID)
            request.addValue(ParseConstants.Values.RestAPIKey, forHTTPHeaderField: ParseConstants.Keys.RestAPIKey)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            } catch {
                print("Could not parse datas JSON: \(request.HTTPBody!)")
                return
            }
            
            let parsed: AnyObject!
            do {
                parsed = try NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .AllowFragments)
            } catch {
                print("Could not parse datas JSON: \(request.HTTPBody!)")
                return
            }
            
            print("PARSED: \(parsed)")
        
    
    
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
            
            performUIUpdatesOnMain {
                self.spinner.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            task.resume()
        }
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