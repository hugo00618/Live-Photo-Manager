//
//  AddAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox

let ACC_DLG_NUM_DEFAULT  = 0
let ACC_DLG_NUM_DROPBOX  = 1
let ACC_DLG_NUM_GDRIVE   = 2
let ACC_DLG_NUM_ONEDRIVE = 3

let IMAGE_NAME_DROPBOX_LOGO = "Image_Dropbox"
let IMAGE_NAME_GDRIVE_LOGO = "Image_GDrive"
let IMAGE_NAME_ONEDRIVE_LOGO = "Image_OneDrive"

let CELL_REUSE_ID_CLOUD_SERVICE = "tableCell_cloudServiceProvider"

class AddAccountVC: UITableViewController {
    // flags
    var cloudAccCheckedNum = 0
    var availableCloudServiceCells = [CloudServiceTableCell]()
    // flag indicating which cloud service is adding
    var addAccountDialog = ACC_DLG_NUM_DEFAULT
    var cloudServicesStatusRefreshed = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // check which scene it is coming from
        switch (addAccountDialog) {
        case ACC_DLG_NUM_DEFAULT:
            availableCloudServiceCells = []
            cloudServicesStatusRefreshed = false
            refreshCloudAccounts()
            break
        case ACC_DLG_NUM_DROPBOX:
            if (Dropbox.authorizedClient == nil) { // authorization failed
                let alertView = UIAlertView(title: "Authorization Failed", message: nil, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        case ACC_DLG_NUM_GDRIVE:
            break
        case ACC_DLG_NUM_ONEDRIVE:
            break
        default:
            break
        }
        addAccountDialog = ACC_DLG_NUM_DEFAULT
        
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (cloudServicesStatusRefreshed) { // refreshed
            return availableCloudServiceCells.count
        } else { // refreshing, display the loading indicator cell
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (cloudServicesStatusRefreshed) { // refreshed
            return availableCloudServiceCells[indexPath.row]
        } else { // refreshing, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cloudServicesStatusRefreshed {
            return 66
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? CloudServiceTableCell {
            switch (selectedCell.serviceProvider!) {
            case CloudServiceProvider.Dropbox:
                addAccountDialog = ACC_DLG_NUM_DROPBOX
                Dropbox.authorizeFromController(self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                break
            case CloudServiceProvider.GDrive:
                break
            case CloudServiceProvider.OneDrive:
                break
            }
        }
    }
    
    // MARK: actions
    @IBAction func onClickCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func appendCloudServiceCell(serviceProvider: CloudServiceProvider) {
        let cloudServiceCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_SERVICE) as! CloudServiceTableCell
        
        // set image
        switch (serviceProvider) {
        case CloudServiceProvider.Dropbox:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_DROPBOX_LOGO)
            break
        case CloudServiceProvider.GDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_GDRIVE_LOGO)
            break
        case CloudServiceProvider.OneDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_ONEDRIVE_LOGO)
            break
        }
        
        // set service provider
        cloudServiceCell.serviceProvider = serviceProvider
        
        availableCloudServiceCells.append(cloudServiceCell)
    }
    
    func refreshCloudAccounts() {
        cloudAccCheckedNum = 0
        
        if let client = Dropbox.authorizedClient {
            // Get the current user's account info
            client.users.getCurrentAccount().response { response, error in
                if response != nil {
                    self.cloudAccChekced()
                } else {
                    print(error!)
                    self.appendCloudServiceCell(CloudServiceProvider.Dropbox)
                    self.cloudAccChekced()
                    
                }
            }
        } else {
            self.appendCloudServiceCell(CloudServiceProvider.Dropbox)
            cloudAccChekced()
        }
        
        self.appendCloudServiceCell(CloudServiceProvider.GDrive)
        cloudAccChekced()
        
        self.appendCloudServiceCell(CloudServiceProvider.OneDrive)
        cloudAccChekced()
    }
    
    func cloudAccChekced() {
        cloudAccCheckedNum += 1
        
        // refresh tableView if all accounts have been checked
        if (cloudAccCheckedNum == CLOUD_SERVICES_NUM) {
            cloudServicesStatusRefreshed = true
            
            // reload data
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
}
