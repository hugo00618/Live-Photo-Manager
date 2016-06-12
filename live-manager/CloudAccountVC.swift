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

let SEGUE_ID_ADD_ACC = "addAccount"

let IMAGE_NAME_DROPBOX_ICON = "Image_Dropbox_square"
let IMAGE_NAME_GDRIVE_ICON = "Image_GDrive_square"
let IMAGE_NAME_ONEDRIVE_ICON = "Image_OneDrive_square"

class CloudAccountVC: UITableViewController, AddAccountDelegate {
    
    var decodedAccConfigs = [CloudAccountConfig]()
    
    /*    override func viewDidLoad() {
     // get cloudAccConfig data
     if let encodedCloudAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // if data exists
     self.encodedCloudAccConfigs = encodedCloudAccConfigs
     } else {
     userDefaults.setObject(encodedCloudAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
     }
     
     // reload accounts
     self.tableView.reloadData()
     refreshCloudAccounts()
     } */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect table cell if swiped back
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
        
        // check if view needs to be reloaded
        if !CloudAccountManager.reloaded { // reload needed
            reloadTableView()
        } else {
            decodedAccConfigs = CloudAccountManager.getDecodedAccConfigs()
        }
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACCOUNTS"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CloudAccountManager.reloaded { // refreshed
            if decodedAccConfigs.count == CLOUD_SERVICES_NUM { // all avaliable cloud services have been added, no "add account" cell needed
                return CLOUD_SERVICES_NUM
            } else { // still has available cloud services to add, present the "add account" button
                return decodedAccConfigs.count + 1
            }
        } else { // refreshing, display the loading indicator cell
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if CloudAccountManager.reloaded { // refreshed
            if indexPath.row == decodedAccConfigs.count { // reaches the end of all user accounts, return "add account" cell
                return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_ADD_ACC)!
            } else {
                return CloudAccountManager.getCloudAccountCell(self.tableView, accConfig: decodedAccConfigs[indexPath.row])
            }
        } else { // refreshing, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch (identifier) {
            case SEGUE_ID_ADD_ACC:
                let addAccVC = (segue.destinationViewController as! UINavigationController).topViewController as! AddAccountVC
                addAccVC.delegate = self
                break
            default:
                break
            }
        }
    }
    
    // MARK: delegate
    func didAddNewAccount() {
        reloadTableView()
    }
    
    
    func reloadTableView() {
        self.tableView.reloadData()
        CloudAccountManager.reload(reloadFirstSection)
    }
    
    func reloadFirstSection() {
        self.decodedAccConfigs = CloudAccountManager.getDecodedAccConfigs()
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
}
