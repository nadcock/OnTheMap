//
//  ViewController.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/10/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    
    var user = StudentInforamion()
    let udacity = Udacity()
    var keyboardPresent = false
    var activeField: UITextField?
    
    @IBAction func loginTapped(sender: UIButton) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlert("Please enter a valid username and password")
        } else {
            setUIEnabled(false)
            udacity.getSession(emailTextField.text!, password: passwordTextField.text!) {
                (key: String, firstName: String, lastName: String, username: String) -> Void in
                self.user.key = key
                self.user.firstName = firstName
                self.user.login = username
                self.user.lastName = lastName
                
                self.completeLogin()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIEnabled(true)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
//        emailTextField.text = "nick@nicksemail.com"
//        passwordTextField.text = "Na0coC77"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        registerForKeyboardNotifications()
        self.setUIEnabled(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    func displayAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TabBarControllerSegue" {
            let nextScene =  segue.destinationViewController as! UITabBarController
            let mapNavViewController = nextScene.viewControllers![0] as! UINavigationController
            let mapVC = mapNavViewController.viewControllers[0] as! MapViewController
            mapVC.user = user
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.performSegueWithIdentifier("TabBarControllerSegue", sender: self)
        }
    }
    
}

extension LoginViewController {
    
    // Keyboard Functions
    
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 10.0, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let _ = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height - 10.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setUIEnabled(enabled: Bool) {
        emailTextField.enabled = enabled
        print("emailTextField.enabled = \(emailTextField.enabled)")
        passwordTextField.enabled = enabled
        print("passwordTextField.enabled = \(passwordTextField.enabled)")
        loginButton?.enabled = enabled
     
        // adjust login button alpha
        if enabled {
            loginButton?.alpha = 1.0
        } else {
            loginButton?.alpha = 0.5
        }
    }
    
    
}


