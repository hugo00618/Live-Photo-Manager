//
//  SettingsDetailsVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

protocol AccountSettingsDetailsDelegate {
    func didRemoveAccount()
}

class AccountSettingsDetailsVC: UITableViewController {
    
    @IBOutlet weak var switch_autoUpload: UISwitch!
    @IBOutlet weak var tableCell_passcodeLock: UITableViewCell!
    @IBOutlet weak var tableCell_signOut: UITableViewCell!
    
    var accountConfig: CloudAccountConfig?
    var delegate: AccountSettingsDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = accountConfig?.serviceProviderName
        switch_autoUpload.on = accountConfig!.autoUpload
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect table cell if swiped back
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    // MARK: UITableViewController
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section != 0) {
            return ""
        }
        
        switch (accountConfig!.serviceProviderName) {
        case "Dropbox":
            return "Automatically uploads Live Photos to your Dropbox's \"Camera Uploads\" folder if enabled."
        case "Google Drive":
            return "Automatically uploads Live Photos to your Google Drive's \"Google Photos\" folder if enabled."
        case "OneDrive":
            return "Automatically uploads Live Photos to your OneDrive's \"Pictures\\Camera Roll\" folder if enabled."
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 2: // sign out
            let signOutConfirmationMessage: String? = accountConfig!.autoUpload ? ("This will turn off Auto Upload for " + accountConfig!.serviceProviderName) : nil
            
            let signOutConfirmationAlert = UIAlertController(title: nil, message: signOutConfirmationMessage, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let signoutAction = UIAlertAction(title: "Unlink", style: UIAlertActionStyle.Destructive, handler: {(action: UIAlertAction) in
                // unlink account
                CloudAccountManager.unlinkAccount(self.accountConfig!.serviceProviderName)
                
                // call back and dismiss current VC
                self.delegate!.didRemoveAccount()
                self.dismissViewControllerAnimated(true, completion: nil)
                })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            signOutConfirmationAlert.addAction(signoutAction)
            signOutConfirmationAlert.addAction(cancelAction)
            
            self.presentViewController(signOutConfirmationAlert, animated: true, completion: {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            })
            break
        default:
            break
        }
    }
    
    // MARK: Actions
    @IBAction func didClickCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didClickSave(sender: AnyObject) {
        // save data and write to userDefaults
        accountConfig?.autoUpload = switch_autoUpload.on
        CloudAccountManager.writeAccConfig(accountConfig!)
        
        // call back
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
