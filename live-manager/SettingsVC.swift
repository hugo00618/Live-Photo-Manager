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

class SettingsVC: UITableViewController, AccountSettingsDetailsDelegate, AddAccountDelegate {
    
    var decodedAccConfigs = [CloudAccountConfig]()
    
    /*override func viewDidLoad() {
     // get cloudAccConfig data
     if let encodedCloudAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // if data exists
     self.encodedCloudAccConfigs = encodedCloudAccConfigs
     } else {
     userDefaults.setObject(encodedCloudAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
     }
     
     // reload accounts
     accountsReloaded = false
     self.tableView.reloadData()
     refreshCloudAccounts()
     }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        return "CLOUD SERVICES"
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
            case SEGUE_ID_SHOW_ACC_SETTINGS_DETAILS:
                let accSettingsDetailsVC = (segue.destinationViewController as! UINavigationController).topViewController as! AccountSettingsDetailsVC
                
                // get selected table cell index
                let selectedRow = self.tableView.indexPathForSelectedRow!.row
                
                // set AccSettingsDetailsVC's accountConfig
                accSettingsDetailsVC.accountConfig = self.decodedAccConfigs[selectedRow]
                
                // set self as AccSettingsDetailsVC's delegate
                accSettingsDetailsVC.delegate = self
                break
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
    func didRemoveAccount() {
        reloadFirstSection()
    }
    
    func didAddNewAccount() {
        reloadFirstSection()
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
