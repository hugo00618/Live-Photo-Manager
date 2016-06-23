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

class CloudFileListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AccountSettingsDetailsProtocol {
    let CELL_REUSE_ID_LIVE_PHOTO_COLLEC = "livePhotoCollection"
    let CELL_REUSE_ID_VIEW_MORE = "viewMore"
    let CELL_REUSE_ID_DIR = "directory"
    
    let SEGUE_ID_SHOW_ACC_SET_DETAIL = "showAccSettingsDetails"
    
    let STORYBOARD_ID_CLOUD_FILE_LIST = "CloudFileListVC"
    
    @IBOutlet weak var table_master: UITableView!
    @IBOutlet weak var barButton_settings: UIBarButtonItem!
    @IBOutlet weak var barButton_upload: UIBarButtonItem!
    
    var accConfig: CloudAccountConfig?
    var folderMetaData: Files.FolderMetadata?
    
    var data = [[AnyObject]]()
    
    var initialized = false
    var thumbnailViewCollapsed = true
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table_master.delegate = self
        self.table_master.dataSource = self
        
        // check root folder or not
        if let folderMetaData = folderMetaData { // subfolder
            // set navigation bar title to current folder name
            self.navigationItem.title = folderMetaData.name
            
            // only show upload bar button on the right
            self.navigationItem.rightBarButtonItems = [barButton_upload]
        } else { // root folder
            // set navigation bar titile to service provider name
            self.navigationItem.title = accConfig?.serviceProviderName
            
            // only show settings bar button on the right
            self.navigationItem.rightBarButtonItems = [barButton_settings]
        }
        
        // show loading view
        let myLoadingPrompt = LoadingPrompt()
        self.view.addSubview(myLoadingPrompt)
        myLoadingPrompt.center = CGPointMake(self.view.bounds.size.width  / 2, self.view.bounds.size.height / 2)
        
        // fetch file list and reload table view
        let myPath = folderMetaData == nil ? "" : folderMetaData!.pathLower
        CloudDataManager.getFileList(CloudServiceProvider(rawValue: accConfig!.serviceProviderName)!, path: myPath) { (cloudLivePhotos, directories) in
            if cloudLivePhotos.count != 0 {
                self.data.append(cloudLivePhotos)
            }
            if directories.count != 0 {
                self.data.append(directories
                )
            }
            
            self.initialized = true
            myLoadingPrompt.removeFromSuperview()
            
            if self.data.count == 0 { // folder rmpty, display prompt
                let folderEmptyPrompt = FullScreenImagePrompt()
                folderEmptyPrompt.label_title.text = "No Live Photos"
                folderEmptyPrompt.label_content.text = "No Live Photos or sub-directories found in this folder."
                
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
        if samplingData as? CloudLivePhoto != nil { // data[section] is [CloudLivePhoto]
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
        
        let samplingData = data[section][0] // get the first element of data[section] as sample
        if samplingData as? CloudLivePhoto != nil { // data[section] is [CloudLivePhoto]
            if data[section].count > 6 { // more than 6 live photos, need "expand" button
                return 2
            }
            return 1
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return data[section].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let samplingData = data[indexPath.section][0] // get the first element of data[section] as sample
        if samplingData as? CloudLivePhoto != nil { // data[section] is [CloudLivePhoto]
            switch indexPath.row {
            case 0: // live photo thumbnails
                if thumbnailViewCollapsed { // collapsed view, return 1 or 2 row's height
                    if data[indexPath.section].count <= 3 {
                        return 106
                    } else {
                        return 213
                    }
                } else { // expanded view, return actual height
                    let numOfRows = ceil(CGFloat(data[indexPath.section].count) / 3.0)
                    return numOfRows * 107 - 1
                }
            case 1: // "view more" button
                return 44
            default:
                return 0
            }
        } else if samplingData as? Files.FolderMetadata != nil { // [Files.FolderMetadata]
            return 50
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myData = data[indexPath.section][indexPath.row]
        if myData as? CloudLivePhoto != nil {
            if indexPath.row == 0 { // photo thumbnails
                let livePhotoListCell = self.table_master!.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_LIVE_PHOTO_COLLEC) as! LivePhotoListCell
                
                livePhotoListCell.collection_master.cloudLivePhotos = data[indexPath.section] as! [CloudLivePhoto]
                
                
                livePhotoListCell.collection_master.delegate = livePhotoListCell.collection_master
                livePhotoListCell.collection_master.dataSource = livePhotoListCell.collection_master
                
                return livePhotoListCell
            }
            // view more button
            return self.table_master!.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_VIEW_MORE)!
        } else if let myData = myData as? Files.FolderMetadata {
            let myCell = self.table_master.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_DIR)!
            
            // set folder name and last modified on
            myCell.textLabel?.text = myData.name
            
            // set camera folder icon for photo upload folder
            switch CloudServiceProvider(rawValue: accConfig!.serviceProviderName)! {
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
        // determine section
        let sender = tableView.cellForRowAtIndexPath(indexPath)
        if let sender = sender as? LivePhotoListCell { // Live Photo thumbnail collection
            
        } else if sender as? ViewMoreTableCell != nil { // "view more" button
            thumbnailViewCollapsed = false
            self.table_master.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowAnimation: UITableViewRowAnimation.Automatic)
        } else if sender as? CloudFolderTableCell != nil { // folder section
            let subFolderFileListVC = self.storyboard?.instantiateViewControllerWithIdentifier(STORYBOARD_ID_CLOUD_FILE_LIST) as! CloudFileListVC
            
            subFolderFileListVC.accConfig = accConfig
            subFolderFileListVC.folderMetaData = data[indexPath.section][indexPath.row] as! Files.FolderMetadata
            
            self.navigationController?.pushViewController(subFolderFileListVC, animated: true)
        }
    }
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = segue.identifier {
            switch segueId {
            case SEGUE_ID_SHOW_ACC_SET_DETAIL:
                let accSetDetailVC = (segue.destinationViewController as! UINavigationController).topViewController as! AccountSettingsDetailsVC
                
                accSetDetailVC.accountConfig = accConfig
                accSetDetailVC.myProtocol = self
            default:
                break
            }
        }
    }
    
    
    // MARK: AccountSettingsDetailsProtocol
    func unlinkAccount() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
