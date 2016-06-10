//
//  CloudAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-09.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox

let CELL_REUSE_ID_LOAD_INDIC = "tableCell_loadingIndicator"
let CELL_REUSE_ID_CLOUD_ACC = "tableCell_cloudAccount"
let CELL_REUSE_ID_ADD_ACC = "tableCell_addAccount"

let IMAGE_NAME_DROPBOX_ICON = "Image_Dropbox_square"
let IMAGE_NAME_GDRIVE_ICON = "Image_GDrive_square"
let IMAGE_NAME_ONEDRIVE_ICON = "Image_OneDrive_square"

let CLOUD_SERVICES_NUM = 3 // total number of cloud services available

class CloudAccountVC: UITableViewController {
    var availableCloudAccountCells = [CloudAccountTableCell]()
    
    // flags
    var cloudServicesStatusRefreshed = false
    var cloudAccCheckedNum = 0 // number of accounts that have been checked
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        availableCloudAccountCells = []
        cloudServicesStatusRefreshed = false
        refreshCloudAccounts()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACCOUNTS"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (cloudServicesStatusRefreshed) { // refreshed
            if (availableCloudAccountCells.count == CLOUD_SERVICES_NUM) { // all avaliable cloud services have been added, no "add account" cell needed
                return CLOUD_SERVICES_NUM
            } else { // still has available cloud services to add, present the "add account" button
                return availableCloudAccountCells.count + 1
            }
        } else { // refreshing, display the loading indicator cell
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (cloudServicesStatusRefreshed) { // refreshed
            if (indexPath.row == availableCloudAccountCells.count) { // reaches the end of all user accounts, return "add account" cell
                return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_ADD_ACC)!
            } else {
                return availableCloudAccountCells[indexPath.row]
            }
        } else { // refreshing, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        }
    }
    
    func refreshCloudAccounts() {
        cloudAccCheckedNum = 0
        
        if let client = Dropbox.authorizedClient {
            // Get the current user's account info
            client.users.getCurrentAccount().response { response, error in
                if let account = response {
                    let dropboxAccCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_ACC) as! CloudAccountTableCell
                    
                    // set icon and label
                    dropboxAccCell.image_icon.image = UIImage(named: IMAGE_NAME_DROPBOX_ICON)
                    dropboxAccCell.label_userName.text = account.name.displayName
                    
                    // set account provider
                    dropboxAccCell.serviceProvider = CloudServiceProvider.Dropbox
                    
                    self.availableCloudAccountCells.append(dropboxAccCell)
                    self.cloudAccChekced()
                } else {
                    print(error!)
                    self.cloudAccChekced()
                }
            }
        } else {
            cloudAccChekced()
        }
        
        cloudAccChekced()
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
