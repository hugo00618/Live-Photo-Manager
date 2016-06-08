//
//  ActionViewController.swift
//  live-manager-action-extension
//
//  Created by Hugo Yu on 2016-06-03.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import PhotosUI

class ActionViewController: UITableViewController {
    
    @IBOutlet var table_master: UITableView!
    @IBOutlet var liveImg_photo: PHLivePhotoView!
    
    var pushedBackFromError = false
    var livePhotoURLs: [NSURL]? = nil
    
    // MARK: UITableViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputItem = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let itemProvider = inputItem.attachments![0] as! NSItemProvider
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeLivePhoto as String) { // live photo
            // live photos can be seen but cannot be accessed (result is nil) as of iOS 9.3.2 (possibly API error). thus live photos are currently regarded as an unsupported file type.
            self.pushToFileUnsupportedScene()
            
            /* //weak var weakImageView = self.imageView
            
            itemProvider.loadItemForTypeIdentifier(kUTTypeLivePhoto as String, options: nil, completionHandler: { (result, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //if let strongImageView = weakImageView {
                    
                    if result == nil {
                        NSLog("************ 2 ************")
                        NSLog(String(error))
                    }
                    
                    if let result = result as? NSURL {
                        NSLog("URL")
                        PHLivePhoto.requestLivePhotoWithResourceFileURLs([result], placeholderImage: nil, targetSize: self.liveImg_photo.bounds.size, contentMode: PHImageContentMode.AspectFit, resultHandler: { (result: PHLivePhoto?, info: [NSObject : AnyObject]) in
                            NSLog("Live photo loaded")
                            self.liveImg_photo.livePhoto = result
                        })
                        
                        //strongImageView.image = UIImage(data: NSData(contentsOfURL: imageURL)!)
                    }
                    //}
                }
            }) */
        } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeZipArchive as String) { // zip
            itemProvider.loadItemForTypeIdentifier(kUTTypeZipArchive as String, options: nil, completionHandler: { (zipURL, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    //if let strongImageView = weakImageView {
                    
                    if let zipURL = zipURL as? NSURL {
                        self.livePhotoURLs = self.unzipLivePhoto(zipURL)
                        if (self.livePhotoURLs != nil) { // if file is supported
                            // retrieve image size
                            let myTargetSize = UIImage(data: NSData(contentsOfURL: self.livePhotoURLs![0])!)!.size
                            
                            // set preview
                            PHLivePhoto.requestLivePhotoWithResourceFileURLs(self.livePhotoURLs!, placeholderImage: nil, targetSize: myTargetSize, contentMode: PHImageContentMode.AspectFit, resultHandler: { (result: PHLivePhoto?, info: [NSObject : AnyObject]) in
                                self.liveImg_photo.livePhoto = result
                            })
                        } else {
                            self.pushToFileUnsupportedScene()
                        }
                    }
                    //}
                }
            })
            
        } else {
            self.pushToFileUnsupportedScene()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if coming from FileUnsupported scene (cancel button tapped)
        if (pushedBackFromError) {
            cancel(self)
        } else { // proceed vc initialization
        // select first save as option by default
        table_master.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if tapped one of the 3 options
        if (tableView == table_master && indexPath.section == 0 && indexPath.row > 0 && indexPath.row < 4) {
            // reset all cells
            for i in 1...3 {
                let myIndexPtah = NSIndexPath(forRow: i, inSection: 0)
                table_master.cellForRowAtIndexPath(myIndexPtah)?.accessoryType = UITableViewCellAccessoryType.None
            }
            
            // checkmark the selected option
            table_master.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        // remove table cell's hightlight
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func save(sender: AnyObject) {
        // find the table cell that has checkmark
        var i: Int
        for (i = 1; i <= 3; i += 1) {
            let myIndexPath = NSIndexPath(forRow: i, inSection: 0)
            if (table_master.cellForRowAtIndexPath(myIndexPath)?.accessoryType == UITableViewCellAccessoryType.Checkmark) {
                break
            }
        }
        
        switch (i) {
        case 1: // live photo
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCreationRequest.creationRequestForAsset()
                request.addResourceWithType(PHAssetResourceType.Photo, fileURL: self.livePhotoURLs![0], options: nil)
                request.addResourceWithType(PHAssetResourceType.PairedVideo, fileURL: self.livePhotoURLs![1], options: nil)
                }, completionHandler: { (success: Bool, error: NSError?) in
                    if (success) {
                        NSLog("Success")
                    } else {
                        NSLog(String(error))
                    }
            })
            break
        case 2: // still photo
            let stillPhoto = UIImage(data: NSData(contentsOfURL: self.livePhotoURLs![0])!)!
            UIImageWriteToSavedPhotosAlbum(stillPhoto, nil, nil, nil)
            break
        case 3: // video
            UISaveVideoAtPathToSavedPhotosAlbum(livePhotoURLs![1].relativePath!, nil, nil, nil)
            break
        default:
            break
        }
        
        self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    // on cancel button tapped
    @IBAction func cancel(sender: AnyObject) {
        self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    func pushToFileUnsupportedScene() {
        // set flag and push to FileUnsupported scene
        pushedBackFromError = true
        self.performSegueWithIdentifier("pushToError", sender: self)
    }
    
    // unzipLivePhoto() consumes the URL of the zip file and returns an array of NSURL's where the first URL is still photo and the second URL is video, or returns nil if fails
    func unzipLivePhoto(zipURL: NSURL) -> [NSURL]? {
        var myArchive: ZZArchive
        do {
            myArchive = try ZZArchive(URL: zipURL, options: [ZZOpenOptionsCreateIfMissingKey: true])
        } catch let error {
            NSLog(String(error))
            return nil
        }
        
        // ZipZap produces a 2-entry zip, while OS X somehow outputs a 5-entry zip, where 3 of them are random files and the entries we actually need are at index 0 and 3.
        if (myArchive.entries.count == 2 || myArchive.entries.count == 5) {
            var firstEntry = myArchive.entries[0]
            var secondEntry = myArchive.entries.count == 2 ? myArchive.entries[1] : myArchive.entries[3]
            
            // check if file types are ok
            if (entriesAreOfCorrectType(firstEntry.fileName, secondName: secondEntry.fileName)) { // first is image, second is video
                
            } else if (entriesAreOfCorrectType(secondEntry.fileName, secondName: firstEntry.fileName)) { // first is video, second is image, need to flip the entries
                let tempEntry = firstEntry
                firstEntry = secondEntry
                secondEntry = tempEntry
            } else { // file type incorrect
                return nil
            }
            
            let imageURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(firstEntry.fileName))
            let videoURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(secondEntry.fileName))
            
            //let fileManager = NSFileManager.defaultManager()
            
            do {
                //try fileManager.createDirectoryAtURL(imageURL, withIntermediateDirectories: true, attributes: nil)
                try firstEntry.newData().writeToURL(imageURL, atomically: false)
            } catch let error {
                NSLog(String(error))
                return nil
            }
            
            do {
                //try fileManager.createDirectoryAtURL(videoURL, withIntermediateDirectories: true, attributes: nil)
                try secondEntry.newData().writeToURL(videoURL, atomically: false)
            } catch let error {
                NSLog(String(error))
                return nil
            }
            
            return [imageURL, videoURL]
        } else {
            return nil
        }
    }
    
    // consumes two file names and determines if the first one is a jpeg image and the second one is a .mov video
    func entriesAreOfCorrectType(firstName: String, secondName: String) -> Bool {
        return ((firstName.hasSuffix(".jpg") || firstName.hasSuffix(".JPG") || firstName.hasSuffix(".jpeg") || firstName.hasSuffix(".JPEG")) && (secondName.hasSuffix(".mov") || secondName.hasSuffix(".MOV")))
    }
}
