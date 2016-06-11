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

class SettingsVC: UITableViewController, ModifyCloudAccountConfigDelegate {
    var myCloudAccountCells = [CloudAccountTableCell]()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var encodedCloudAccConfigs = [NSData](count: CLOUD_SERVICES_NUM, repeatedValue: NSData())
    
    // flags
    var accountsReloaded = false
    var cloudAccCheckedNum = 0 // number of accounts that have been checked
    
    override func viewDidLoad() {
        // get cloudAccConfig data
        if let encodedCloudAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // if data exists
            self.encodedCloudAccConfigs = encodedCloudAccConfigs
        } else {
            userDefaults.setObject(encodedCloudAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
        }
        
        // reload accounts
        myCloudAccountCells = []
        accountsReloaded = false
        self.tableView.reloadData()
        refreshCloudAccounts()
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "CLOUD SERVICES"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (accountsReloaded) { // refreshed
            return myCloudAccountCells.count
        } else { // refreshing, display the loading indicator cell
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (accountsReloaded) { // refreshed
            return myCloudAccountCells[indexPath.row]
        } else { // refreshing, display the loading indicator cell
            return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LOAD_INDIC)!
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch (identifier) {
            case SEGUE_ID_SHOW_ACC_SETTINGS_DETAILS:
                let accSettingsDetailsVC = segue.destinationViewController as! AccountSettingsDetailsVC
                
                // get selected table cell index
                let selectedRow = self.tableView.indexPathForSelectedRow!.row
                
                // set AccSettingsDetailsVC's accountConfig
                accSettingsDetailsVC.accountConfig = NSKeyedUnarchiver.unarchiveObjectWithData(self.encodedCloudAccConfigs[selectedRow]) as! CloudAccountConfig
                // set self as AccSettingsDetailsVC's;s delegate
                accSettingsDetailsVC.delegate = self
                break
            default:
                break
            }
        }
    }
    
    // MARK: delegate
    func didModifyCloudAccountConfig(newAccConfig: CloudAccountConfig, atIndex: Int) {
        updateEncodedConfigs(newAccConfig, atIndex: atIndex)
    }
    
    func getCloudAccountCell(serviceProvider: CloudServiceProvider, userName: String) -> CloudAccountTableCell{
        let cloudAccountCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_ACC) as! CloudAccountTableCell
        
        // set icon
        switch (serviceProvider) {
        case .Dropbox:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_DROPBOX_ICON)
            break
        case .GDrive:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_GDRIVE_ICON)
            break
        case .OneDrive:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_ONEDRIVE_ICON)
            break
        }
        
        cloudAccountCell.label_userName.text = userName
        
        cloudAccountCell.serviceProvider = serviceProvider
        
        return cloudAccountCell
    }
    
    func checkAccount(serviceProvider: CloudServiceProvider, completion: (() -> Void)?) {
        switch (serviceProvider) {
        case .Dropbox:
            if let client = Dropbox.authorizedClient {
                // Get the current user's account info
                client.users.getCurrentAccount().response { response, error in
                    if let account = response {
                        let dropboxAccCell = self.getCloudAccountCell(CloudServiceProvider.Dropbox, userName: account.name.displayName)
                        
                        // set config file
                        if let cloudAccConfig = NSKeyedUnarchiver.unarchiveObjectWithData(self.encodedCloudAccConfigs[0]) as? CloudAccountConfig {
                            dropboxAccCell.accountConfig = cloudAccConfig
                        } else {
                            let newCloudAccConfig = CloudAccountConfig(serviceProviderName: "Dropbox")
                            dropboxAccCell.accountConfig = newCloudAccConfig
                            
                            self.updateEncodedConfigs(newCloudAccConfig, atIndex: 0)
                        }
                        self.myCloudAccountCells.append(dropboxAccCell)
                        
                        completion?()
                    } else {
                        print(error!)
                        completion?()
                    }
                }
            } else {
                completion?()
            }
            break
        case .GDrive:
            completion?()
            break
        case .OneDrive:
            completion?()
            break
        }
    }
    
    func refreshCloudAccounts() {
        cloudAccCheckedNum = 0
        
        // check all services
        checkAccount(CloudServiceProvider.Dropbox, completion: cloudAccChekced)
        checkAccount(CloudServiceProvider.GDrive, completion: cloudAccChekced)
        checkAccount(CloudServiceProvider.OneDrive, completion: cloudAccChekced)
    }
    
    func cloudAccChekced() {
        cloudAccCheckedNum += 1
        
        // refresh tableView if all accounts have been checked
        if (cloudAccCheckedNum == CLOUD_SERVICES_NUM) {
            accountsReloaded = true
            
            // reload data
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func updateEncodedConfigs(newAccConfig: CloudAccountConfig, atIndex: Int) {
        encodedCloudAccConfigs[atIndex] = NSKeyedArchiver.archivedDataWithRootObject(newAccConfig)
        userDefaults.setObject(self.encodedCloudAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
    }
    
}
