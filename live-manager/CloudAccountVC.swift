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

let USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS = "cloudAccConfigs"

let IMAGE_NAME_DROPBOX_ICON = "Image_Dropbox_square"
let IMAGE_NAME_GDRIVE_ICON = "Image_GDrive_square"
let IMAGE_NAME_ONEDRIVE_ICON = "Image_OneDrive_square"

let CLOUD_SERVICES_NUM = 3 // total number of cloud services available

class CloudAccountVC: UITableViewController, AddAccountDelegate {
    var myCloudAccountCells = [CloudAccountTableCell]()
    var cloudServicesAvailableToAdd = [CloudServiceProvider?](count: CLOUD_SERVICES_NUM, repeatedValue: nil)
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect table cell if swiped back
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACCOUNTS"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (accountsReloaded) { // refreshed
            if (myCloudAccountCells.count == CLOUD_SERVICES_NUM) { // all avaliable cloud services have been added, no "add account" cell needed
                return CLOUD_SERVICES_NUM
            } else { // still has available cloud services to add, present the "add account" button
                return myCloudAccountCells.count + 1
            }
        } else { // refreshing, display the loading indicator cell
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (accountsReloaded) { // refreshed
            if (indexPath.row == myCloudAccountCells.count) { // reaches the end of all user accounts, return "add account" cell
                return self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_ADD_ACC)!
            } else {
                return myCloudAccountCells[indexPath.row]
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
                
                var availableCloudServiceCells = [CloudServiceTableCell]()
                for cloudService in cloudServicesAvailableToAdd {
                    if let cloudService = cloudService {
                        availableCloudServiceCells.append(getCloudServiceCell(addAccVC.tableView, serviceProvider: cloudService))
                    }
                }
                
                addAccVC.delegate = self
                addAccVC.availableCloudServiceCells = availableCloudServiceCells
                break
            default:
                break
            }
        }
    }
    
    // MARK: delegate
    func didAddNewAccount(serviceProvider: CloudServiceProvider) {
        checkAccount(serviceProvider, completion: {
            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        })
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
    
    func getCloudServiceCell(tableView: UITableView, serviceProvider: CloudServiceProvider) -> CloudServiceTableCell{
        let cloudServiceCell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_SERVICE) as! CloudServiceTableCell
        
        // set image
        switch (serviceProvider) {
        case .Dropbox:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_DROPBOX_LOGO)
            break
        case .GDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_GDRIVE_LOGO)
            break
        case .OneDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_ONEDRIVE_LOGO)
            break
        }
        
        cloudServiceCell.serviceProvider = serviceProvider
        
        return cloudServiceCell
    }
    
    func checkAccount(serviceProvider: CloudServiceProvider, completion: (() -> Void)?) {
        switch (serviceProvider) {
        case .Dropbox:
            cloudServicesAvailableToAdd[0] = CloudServiceProvider.Dropbox
            if let client = Dropbox.authorizedClient {
                // Get the current user's account info
                client.users.getCurrentAccount().response { response, error in
                    if let account = response {
                        let dropboxAccCell = self.getCloudAccountCell(CloudServiceProvider.Dropbox, userName: account.name.displayName)
                        
                        self.myCloudAccountCells.append(dropboxAccCell)
                        self.cloudServicesAvailableToAdd[0] = nil
                        
                        // create config file if it doesn't exist
                        if (NSKeyedUnarchiver.unarchiveObjectWithData(self.encodedCloudAccConfigs[0]) as? CloudAccountConfig) == nil {
                            self.encodedCloudAccConfigs[0] = NSKeyedArchiver.archivedDataWithRootObject(CloudAccountConfig(serviceProviderName: "Dropbox"))
                            self.userDefaults.setObject(self.encodedCloudAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
                        }
                        
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
            cloudServicesAvailableToAdd[1] = CloudServiceProvider.GDrive
            completion?()
            break
        case .OneDrive:
            cloudServicesAvailableToAdd[2] = CloudServiceProvider.OneDrive
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
    
}
