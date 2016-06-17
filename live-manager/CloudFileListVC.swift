//
//  CloudFileListVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-16.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import SwiftyDropbox
import Photos
import PhotosUI

class CloudFileListVC: UITableViewController {
    let CELL_REUSE_ID_LIVE_PHOTO_COLLEC = "livePhotoCollection"
    let CELL_REUSE_ID_DIR = "directory"
    
    let STORYBOARD_ID_CLOUD_FILE_LIST = "CloudFileListVC"
    
    var accServiceProvider: CloudServiceProvider?
    var folderMetaData: Files.FolderMetadata?
    
    var data = [[AnyObject]]()
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar title
        if let folderMetaData = folderMetaData { // subfolder
            self.navigationItem.title = folderMetaData.name
        } else { // root folder
            self.navigationItem.title = accServiceProvider?.rawValue
        }
        
        // fetch file list and reload table view
        let myPath = folderMetaData == nil ? "" : folderMetaData!.pathLower
        CloudDataManager.getFileList(accServiceProvider!, path: myPath) { (livePhotos, directories) in
            if livePhotos.count != 0 {
                self.data.append(livePhotos)
            }
            if directories.count != 0 {
                self.data.append(directories
                )
            }
            self.tableView.reloadData()
        }
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
        return data.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let samplingData = data[section][0] // get the first element of data[section] as sample
        if samplingData as? PHLivePhoto != nil { // data[section] is [PHLivePhoto]
            return "LIVE PHOTOS"
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return "FOLDERS"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let samplingData = data[indexPath.section][0] // get the first element of data[section] as sample
        if samplingData as? PHLivePhoto != nil { // data[section] is [PHLivePhoto]
            return 0
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return 50
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myData = data[indexPath.section][indexPath.row]
        if let myData = myData as? PHLivePhoto {
            return UITableViewCell()
        } else if let myData = myData as? Files.FolderMetadata {
            let myCell = self.tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_DIR)!
            
            // set folder name and last modified on
            myCell.textLabel?.text = myData.name
            
            // set camera folder icon for photo upload folder
            switch accServiceProvider! {
            case .Dropbox:
                if myData.pathLower == "/camera uploads"{
                    myCell.imageView?.image = UIImage(named: "Image_Folder_Camera")
                }
                break
            case .GDrive:
                break
            case .OneDrive:
                break
            }
            
            return myCell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let senderData = data[indexPath.section][indexPath.row]
        if let senderData = senderData as? PHLivePhoto { // Live Photo
            
        } else if let senderData = senderData as? Files.FolderMetadata { // Files.FolderMetadta
            let subFolderFileListVC = self.storyboard?.instantiateViewControllerWithIdentifier(STORYBOARD_ID_CLOUD_FILE_LIST) as! CloudFileListVC
            
            subFolderFileListVC.accServiceProvider = accServiceProvider
            subFolderFileListVC.folderMetaData = senderData
            
            self.navigationController?.pushViewController(subFolderFileListVC, animated: true)
        }
    }
}
