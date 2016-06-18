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

class CloudFileListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let CELL_REUSE_ID_LIVE_PHOTO_COLLEC = "livePhotoCollection"
    let CELL_REUSE_ID_DIR = "directory"
    
    let STORYBOARD_ID_CLOUD_FILE_LIST = "CloudFileListVC"
    
    @IBOutlet weak var table_master: UITableView!
    
    var accServiceProvider: CloudServiceProvider?
    var folderMetaData: Files.FolderMetadata?
    
    var data = [[AnyObject]]()
    
    var initialized = false
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table_master.delegate = self
        self.table_master.dataSource = self
        
        // set navigation bar title
        if let folderMetaData = folderMetaData { // subfolder
            self.navigationItem.title = folderMetaData.name
        } else { // root folder
            self.navigationItem.title = accServiceProvider?.rawValue
        }
        
        // show loading view
        let myLoadingPrompt = LoadingPrompt()
        self.view.addSubview(myLoadingPrompt)
        myLoadingPrompt.center = CGPointMake(self.view.bounds.size.width  / 2, self.view.bounds.size.height / 2)
        
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
            
            self.initialized = true
            myLoadingPrompt.removeFromSuperview()
            
            if self.data.count == 0 { // folder rmpty, display prompt
                let folderEmptyPrompt = FullScreenImagePrompt()
                folderEmptyPrompt.label_title.text = "Folder is Empty"
                folderEmptyPrompt.label_content.text = "No Live Photos or subfolders in this directory."
                
                self.view.addSubview(folderEmptyPrompt)
                folderEmptyPrompt.bounds = self.view.bounds
                folderEmptyPrompt.center = CGPointMake(self.view.bounds.size.width  / 2, self.view.bounds.size.height / 2)
            } else {
                self.table_master.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // deselect table cell if swiped back
        if let selectedIndexPath = self.table_master.indexPathForSelectedRow {
            self.table_master.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    // MARK: UITableViewController
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !initialized {
            return 0
        }
        
        return data.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let samplingData = data[section][0] // get the first element of data[section] as sample
        if samplingData as? PHLivePhoto != nil { // data[section] is [PHLivePhoto]
            return "LIVE PHOTOS"
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return "FOLDERS"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !initialized {
            return 0
        }
        
        return data[section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let samplingData = data[indexPath.section][0] // get the first element of data[section] as sample
        if samplingData as? PHLivePhoto != nil { // data[section] is [PHLivePhoto]
            return 0
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return 50
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myData = data[indexPath.section][indexPath.row]
        if let myData = myData as? PHLivePhoto {
            return UITableViewCell()
        } else if let myData = myData as? Files.FolderMetadata {
            let myCell = self.table_master.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_DIR)!
            
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
