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
    
    let parse = Parse()
    
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        refresh(UIBarButtonItem())
        tableView.reloadData()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let annotations = StudentData.annotations else {
            return 0
        }
        return annotations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mediaURL = StudentData.locations![indexPath.row].mediaURL
        
        if let url = NSURL(string: mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ListViewCell = self.tableView.dequeueReusableCellWithIdentifier("ListViewCell") as! ListViewCell
        
        let nameString = "\(StudentData.locations![indexPath.row].firstName) \(StudentData.locations![indexPath.row].lastName)"
        
        print(nameString)
        
        cell.nameLabel.text = nameString
        
        return cell
    }
    
    @IBAction func logoutTapped(sender: AnyObject) {
        parse.logout({}, completionHandler: {
            
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        parse.getStudentLocations({}) { locations, annotations -> Void in
            
            StudentData.locations = locations
            StudentData.annotations = annotations
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
    }
    
}
