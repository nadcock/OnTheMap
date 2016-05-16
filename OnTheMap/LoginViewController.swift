//
//  ViewController.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/10/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet var emailTextField: LoginTextField!
    @IBOutlet var passwordTextField: LoginTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!

    var keyboardPresent = false
    var activeField: UITextField?
    
    @IBAction func loginTapped(sender: UIButton) {
        setUIEnabled(false)
        let errorHandler = {
            self.setUIEnabled(true)
        }
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlert("Please enter a valid username and password")
        } else {
            Udacity.getSession(emailTextField.text!, password: passwordTextField.text!, errorHandler: errorHandler) {
                (key: String, firstName: String, lastName: String, username: String) -> Void in
                StudentData.key = key
                StudentData.firstName = firstName
                StudentData.login = username
                StudentData.lastName = lastName
                
                self.completeLogin()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setUIEnabled(true)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        registerForKeyboardNotifications()
        print("ViewWillAppear Called")
        self.setUIEnabled(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    override func displayAlert(alertMessage: String) {
        let alertController = DBAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {
            (action) in self.setUIEnabled(true)
            })
        alertController.show()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        print("keyboardWasShown")
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
        print("keyboardWillBeHidden")
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height - 10.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        //self.activeField?.resignFirstResponder()
        self.scrollView.scrollEnabled = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        if textField.isEqual(passwordTextField) {
            self.loginTapped(loginButton)
            return true
        } else {
            return false
        }
        
    }
    
    
    private func setUIEnabled(enabled: Bool) {
        emailTextField.userInteractionEnabled = enabled
        print("emailTextField.enabled = \(emailTextField.enabled)")
        passwordTextField.userInteractionEnabled = enabled
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

extension UIViewController {
    
    func displayAlert(alertMessage: String) {
        let alertController = DBAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
        alertController.show()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


