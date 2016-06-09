//
//  CloudAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-09.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox

class CloudAccountVC: UITableViewController {
    
    @IBOutlet weak var tableCell_loadingIndicator: UITableViewCell!
    @IBOutlet weak var tableCell_dropboxAcc: UITableViewCell!
    @IBOutlet weak var tableCell_gDriveAcc: UITableViewCell!
    @IBOutlet weak var tableCell_oneDriveAcc: UITableViewCell!
    
    var cloudAccCheckedNum = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cloudAccCheckedNum = 0
        
        if let client = Dropbox.authorizedClient {
            // Get the current user's account info
            client.users.getCurrentAccount().response { response, error in
                if let account = response {
                    dispatch_async(dispatch_get_main_queue(), {() in
                        self.tableCell_dropboxAcc!.textLabel?.text = account.name.displayName
                        self.tableCell_dropboxAcc.hidden = false
                        
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        
                        self.cloudAccChekced()
                    })
                } else {
                    print(error!)
                }
            }
        } else {
            cloudAccChekced()
        }
        
        cloudAccChekced()
        cloudAccChekced()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            if (tableCell_loadingIndicator.hidden) {
                return 0
            }
            break
        case 1:
            if (tableCell_dropboxAcc.hidden) {
                return 0
            }
            break
        case 2:
            if (tableCell_gDriveAcc.hidden) {
                return 0
            }
            break
        case 3:
            if (tableCell_oneDriveAcc.hidden) {
                return 0
            }
            break
        default:
            break
        }
        return 44
    }
    
    func cloudAccChekced() {
        cloudAccCheckedNum += 1
        
        if (cloudAccCheckedNum == 3) {
            tableCell_loadingIndicator.hidden = true
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
}
