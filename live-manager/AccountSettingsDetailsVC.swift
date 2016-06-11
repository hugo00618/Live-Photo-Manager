//
//  SettingsDetailsVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

protocol ModifyCloudAccountConfigDelegate {
    func didModifyCloudAccountConfig(newAccConfig: CloudAccountConfig, atIndex: Int)
}

class AccountSettingsDetailsVC: UITableViewController {
    
    @IBOutlet weak var switch_autoUpload: UISwitch!
    @IBOutlet weak var tableCell_passcodeLock: UITableViewCell!
    @IBOutlet weak var tableCell_signOut: UITableViewCell!
    
    var accountConfig: CloudAccountConfig?
    var delegate: ModifyCloudAccountConfigDelegate?
    
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
    
    // MARK: Actions
    @IBAction func didClickCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didClickSave(sender: AnyObject) {
        // save data
        accountConfig?.autoUpload = switch_autoUpload.on
        
        // call back
        delegate?.didModifyCloudAccountConfig(accountConfig!, atIndex: getServiceProviderIndex())
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getServiceProviderIndex() -> Int {
        switch (accountConfig!.serviceProviderName) {
        case "Dropbox":
            return 0
        case "Google Drive":
            return 1
        case "OneDrive":
            return 2
        default:
            return -1
        }
    }
}
