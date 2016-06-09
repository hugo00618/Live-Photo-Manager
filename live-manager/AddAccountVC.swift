//
//  AddAccountVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox

class AddAccountVC: UITableViewController {
    
    // MARK: UITableViewController
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0: // Dropbox
            Dropbox.authorizeFromController(self)
            
            // remove cell's highlight
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            if (Dropbox.authorizedClient != nil) { // if user authroized
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertView = UIAlertView(title: "Authorization Faild", message: nil, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
            break
        case 1: // Google Drive
            break
        case 2: // One Drive
            break
        default:
            break
        }
    }
    

    // MARK: actions
    @IBAction func onClickCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
