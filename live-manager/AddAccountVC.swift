//
//  AddAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox

let IMAGE_NAME_DROPBOX_LOGO = "Image_Dropbox"
let IMAGE_NAME_GDRIVE_LOGO = "Image_GDrive"
let IMAGE_NAME_ONEDRIVE_LOGO = "Image_OneDrive"

let CELL_REUSE_ID_CLOUD_SERVICE = "tableCell_cloudServiceProvider"

enum AddAccountDialog {
    case Default
    case Dropbox
    case GDrive
    case OneDrive
}

class AddAccountVC: UITableViewController {
    let availableCloudServices = CloudAccountManager.getAvailableCloudServices()
    
    // flag indicating which cloud service is adding
    var addAccountDialog = AddAccountDialog.Default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationIsActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func applicationIsActive(notification: NSNotification) {
        // check incoming scene
        switch (addAccountDialog) {
        case .Dropbox:
            if let client = Dropbox.authorizedClient { // authorization succeeded
                // Get the current user's account info
                client.users.getCurrentAccount().response { response, error in
                    if let account = response { // success
                        CloudAccountManager.writeAccConfig(CloudAccountConfig(serviceProviderName: CloudServiceProvider.Dropbox.rawValue, userName: account.name.displayName))
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print(error!)
                    }
                }
            } else { // authorization failed
                let alertView = UIAlertView(title: "Authorization Failed", message: nil, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
            break
        case .GDrive:
            break
        case .OneDrive:
            break
        default:
            break
        }
        
        addAccountDialog = AddAccountDialog.Default
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableCloudServices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return CloudAccountManager.getCloudServiceCell(self.tableView, serviceProvider: availableCloudServices[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? CloudServiceTableCell {
            switch (selectedCell.serviceProvider!) {
            case .Dropbox:
                addAccountDialog = AddAccountDialog.Dropbox
                showLoadingHUD()
                Dropbox.authorizeFromController(self)
                break
            case .GDrive:
                addAccountDialog = AddAccountDialog.GDrive
                break
            case .OneDrive:
                addAccountDialog = AddAccountDialog.OneDrive
                break
            }
        }
    }
    
    // MARK: actions
    @IBAction func onClickCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let offSetY = self.navigationController!.navigationBar.frame.size.height / -2.0 * UIScreen.mainScreen().scale
        hud.offset = CGPoint(x: 0.0, y: offSetY)
    }
}
