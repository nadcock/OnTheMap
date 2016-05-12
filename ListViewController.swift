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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.parse.annotations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mediaURL = appDelegate.parse.locations[indexPath.row].mediaURL
        
        if let url = NSURL(string: mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ListViewCell = self.tableView.dequeueReusableCellWithIdentifier("ListViewCell") as! ListViewCell
        
        let nameString = "\(appDelegate.parse.locations[indexPath.row].firstName) \(appDelegate.parse.locations[indexPath.row].lastName)"
        
        print(nameString)
        
        cell.nameLabel.text = nameString
        
        return cell
    }
    
    @IBAction func logoutTapped(sender: AnyObject) {
        appDelegate.parse.logout(completionHandler: {
            
            performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
            self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        appDelegate.parse.getStudentLocations(completionHandler: {
            self.tableView.reloadData()
            })
    }
    
}
