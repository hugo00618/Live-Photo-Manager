//
//  AddAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox
import MBProgressHUD

let IMAGE_NAME_DROPBOX_LOGO = "Image_Dropbox"
let IMAGE_NAME_GDRIVE_LOGO = "Image_GDrive"
let IMAGE_NAME_ONEDRIVE_LOGO = "Image_OneDrive"

/*enum AddAccountDialog {
 case Default
 case Dropbox
 case GDrive
 case OneDrive
 }*/

class AddAccountVC: UITableViewController {
    let CELL_REUSE_ID_CLOUD_SERVICE = "tableCell_cloudServiceProvider"
    
    let availableCloudServices = CloudAccountManager.getAvailableCloudServices()
    
    // flag indicating which cloud service is adding
    var addAccServiceProvider: CloudServiceProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationIsActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func applicationIsActive(notification: NSNotification) {
        // check incoming scene
        if let addAccServiceProvider = addAccServiceProvider {
            switch (addAccServiceProvider) {
            case .Dropbox:
                if let client = Dropbox.authorizedClient { // authorization succeeded
                    // Get the current user's account info
                    client.users.getCurrentAccount().response { response, error in
                        if let account = response { // success
                            CloudAccountManager.writeAccConfig(CloudAccountConfig(serviceProviderName: CloudServiceProvider.Dropbox.rawValue, userName: account.name.displayName))
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            print(error!)
                        }
                    }
                } else { // authorization failed
                    showFailToLinkAlert(addAccServiceProvider)
                }
                break
            case .GDrive:
                break
            case .OneDrive:
                break
            }
            
            self.addAccServiceProvider = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCloudServices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get reusable cell
        let myCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_SERVICE) as! CloudServiceTableCell
        return CloudAccountManager.getCloudServiceCell(myCell, serviceProvider: availableCloudServices[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? CloudServiceTableCell {
            addAccServiceProvider = selectedCell.serviceProvider!
            showLoadingHUD()
            
            switch (selectedCell.serviceProvider!) {
            case .Dropbox:
                Dropbox.authorizeFromController(self)
                break
            case .GDrive:
                break
            case .OneDrive:
                break
            }
        }
    }
    
    // MARK: actions
    @IBAction func onClickCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        //hud.defaultMotionEffectsEnabled = !UIAccessibilityIsReduceMotionEnabled()
        let yOffset = self.navigationController!.navigationBar.frame.size.height / -2.0 * UIScreen.mainScreen().scale
        //hud.yOffset = Float(yOffset)
        //hud.offset = CGPoint(x: 0.0, y: yOffset)
    }
    
    func showFailToLinkAlert(serviceProvider: CloudServiceProvider) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
        // show alert
        let failedToAddAlert = UIAlertController(title: String(format: "Failed to Link to %@", serviceProvider.rawValue), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        failedToAddAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (alertAction) in
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }))
        
        self.presentViewController(failedToAddAlert, animated: true, completion: nil)
    }
}
