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

protocol AddAccountDelegate {
    func didAddNewAccount(serviceProvider: CloudServiceProvider)
}

class AddAccountVC: UITableViewController {
    var availableCloudServiceCells = [CloudServiceTableCell]()
    var delegate: AddAccountDelegate?
    
    // flag indicating which cloud service is adding
    var addAccountDialog = ACC_DLG_NUM_DEFAULT
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // check which scene it is coming from
        switch (addAccountDialog) {
        case ACC_DLG_NUM_DROPBOX:
            if (Dropbox.authorizedClient != nil) { // authorization success
                delegate?.didAddNewAccount(CloudServiceProvider.Dropbox)
            } else { // authorization failed
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
        return availableCloudServiceCells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return availableCloudServiceCells[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? CloudServiceTableCell {
            switch (selectedCell.serviceProvider!) {
            case CloudServiceProvider.Dropbox:
                addAccountDialog = ACC_DLG_NUM_DROPBOX
                Dropbox.authorizeFromController(self)
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
}
