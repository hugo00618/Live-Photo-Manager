//
//  CloudAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-09.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox
import MBProgressHUD
import Photos
import PhotosUI

let IMAGE_NAME_DROPBOX_ICON = "Image_Dropbox_square"
let IMAGE_NAME_GDRIVE_ICON = "Image_GDrive_square"
let IMAGE_NAME_ONEDRIVE_ICON = "Image_OneDrive_square"

class CloudAccountVC: UITableViewController {
    let CELL_REUSE_ID_LOAD_INDIC = "tableCell_loadingIndicator"
    let CELL_REUSE_ID_CLOUD_ACC = "tableCell_cloudAccount"
    let CELL_REUSE_ID_ADD_ACC = "tableCell_addAccount"
    
    let SEGUE_ID_ADD_ACC = "addAccount"
    let SEGUE_ID_SHOW_ACC_FILE_LIST = "showAccountFileList"
    
    var decodedAccConfigs = [CloudAccountConfig]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add observer for Cloud Account changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cloudAccUpdated), name: NOTIFICATION_NAME_CLOUD_ACC_UPDATED, object: nil)
        
        // reload
        reloadFirstSection()
    }
    
    func cloudAccUpdated() {
        reloadFirstSection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect table cell if swiped back
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
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
        if CloudAccountManager.reloading { // reloading, display the loading indicator cell
            return 1
        } else {
            if decodedAccConfigs.count == CLOUD_SERVICES_NUM { // all avaliable cloud services have been added, no "add account" cell needed
                return CLOUD_SERVICES_NUM
            } else { // still has available cloud services to add, present the "add account" button
                return decodedAccConfigs.count + 1
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if CloudAccountManager.reloading { // reloading, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        } else { // reloaded
            if indexPath.row == decodedAccConfigs.count { // reaches the end of all user accounts, return "add account" cell
                return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_ADD_ACC)!
            } else {
                // get reusable cell
                let myCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_ACC) as! CloudAccountTableCell
                return CloudAccountManager.getCloudAccountCell(myCell, accConfig: decodedAccConfigs[indexPath.row])
            }
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case SEGUE_ID_SHOW_ACC_FILE_LIST:
            if let destinationVC = segue.destinationViewController as? CloudFileListVC {
                destinationVC.accConfig = (sender as! CloudAccountTableCell).accountConfig
            }
            break
        default:
            break
        }
    }
    
    
    
    func reloadFirstSection() {
        self.decodedAccConfigs = CloudAccountManager.getDecodedAccConfigs()
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
}
