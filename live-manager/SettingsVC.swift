//
//  SettingsVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox

let SEGUE_ID_SHOW_ACC_SETTINGS_DETAILS = "showAccSettingsDetails"

class SettingsVC: UITableViewController {
    
    var decodedAccConfigs = [CloudAccountConfig]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add observer for Cloud Account changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cloudAccUpdated), name: NOTIFICATION_NAME_CLOUD_ACC_UPDATED, object: nil)
        
        reloadFirstSection()
    }
    
    func cloudAccUpdated() {
        reloadFirstSection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "CLOUD STORGAE ACCOUNTS"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CloudAccountManager.reloading { // reloading, display the loading indicator cell
            return 1
        } else { // reloaded
            if decodedAccConfigs.count == CLOUD_SERVICES_NUM { // all avaliable cloud services have been added, no "add account" cell needed
                return CLOUD_SERVICES_NUM
            } else { // still has available cloud services to add, present the "add account" button
                return decodedAccConfigs.count + 1
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (CloudAccountManager.reloading) { // reloading, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        } else { // reloaded
            if indexPath.row == decodedAccConfigs.count { // reaches the end of all user accounts, return "add account" cell
                return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_ADD_ACC)!
            } else {
                return CloudAccountManager.getCloudAccountCell(self.tableView, accConfig: decodedAccConfigs[indexPath.row])
            }
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch (identifier) {
            case SEGUE_ID_SHOW_ACC_SETTINGS_DETAILS:
                let accSettingsDetailsVC = (segue.destinationViewController as! UINavigationController).topViewController as! AccountSettingsDetailsVC
                
                // get selected table cell index
                let selectedRow = self.tableView.indexPathForSelectedRow!.row
                
                // set AccSettingsDetailsVC's accountConfig
                accSettingsDetailsVC.accountConfig = self.decodedAccConfigs[selectedRow]
                
                break
            case SEGUE_ID_ADD_ACC:
                let addAccVC = (segue.destinationViewController as! UINavigationController).topViewController as! AddAccountVC
                break
            default:
                break
            }
        }
    }
    
    func reloadFirstSection() {
        self.decodedAccConfigs = CloudAccountManager.getDecodedAccConfigs()
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}
