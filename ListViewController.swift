//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Nick on 5/9/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit

class ListViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
}

class ListViewController: UITableViewController {
    
    var user: StudentInforamion?
    let parse = Parse()
    
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        let tbController =  self.tabBarController! as UITabBarController
        let mapNavViewController = tbController.viewControllers![0] as! UINavigationController
        let mapVC = mapNavViewController.viewControllers[0] as! MapViewController
        user = mapVC.user
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user!.annotations!.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mediaURL = user!.locations![indexPath.row].mediaURL
        
        if let url = NSURL(string: mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ListViewCell = self.tableView.dequeueReusableCellWithIdentifier("ListViewCell") as! ListViewCell
        
        let nameString = "\(user!.locations![indexPath.row].firstName) \(user!.locations![indexPath.row].lastName)"
        
        print(nameString)
        
        cell.nameLabel.text = nameString
        
        return cell
    }
    
    @IBAction func logoutTapped(sender: AnyObject) {
        parse.logout(completionHandler: {
            
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        parse.getStudentLocations() { locations, annotations -> Void in
            
            self.user!.locations = locations
            self.user!.annotations = annotations
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
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
