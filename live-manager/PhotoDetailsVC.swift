//
//  PhotoDetailsVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoDetailsVC: UIViewController, PHPhotoLibraryChangeObserver, PHLivePhotoViewDelegate {
    var asset: PHAsset!
    var assetResource: [PHAssetResource]!
    
    var barsHidden: Bool!
    var preparedZipURL: NSURL?
    var videoURL: NSURL?
    var universalFileName: String!
    
    //var hud:MBProgressHUD?
    
    @IBOutlet weak var liveImg_photo: PHLivePhotoView!
    @IBOutlet weak var progress_load: UIProgressView!
    
    @IBOutlet weak var barBtn_action: UIBarButtonItem!
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear back button text
        let barBtn_back = UIBarButtonItem()
        barBtn_back.title = ""
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = barBtn_back;
        
        // set navigation bar title to creation date and generate file name
        if (asset.creationDate != nil) {
            // navigation bar title
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .NoStyle
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            self.navigationItem.title = dateFormatter.stringFromDate(asset.creationDate!)
            
            // dropbox style file name
            dateFormatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
            universalFileName = dateFormatter.stringFromDate(asset.creationDate!)
        }
        
        liveImg_photo.delegate = self
        liveImg_photo.contentMode = UIViewContentMode.ScaleAspectFit
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show toolbar, hide bars on tap
        self.navigationController?.toolbarHidden = false
        self.navigationController?.hidesBarsOnTap = true
        
        // enable buttons
        
        updateImage()
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // hide toolbar, undo hide bars on tap
        self.navigationController?.toolbarHidden = true
        self.navigationController?.hidesBarsOnTap = false
        
        /* // hide hud
        if (hud != nil) {
            hud!.hideAnimated(true)
        } */
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        cleanup()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        let hide = (navigationController?.navigationBarHidden)!
        
        // set live photo's background colour
        if (self.liveImg_photo != nil) {
            if (hide) {
                self.liveImg_photo.backgroundColor = UIColor.blackColor()
            } else {
                self.liveImg_photo.backgroundColor = UIColor.whiteColor()
            }
        }
        
        // synchronized visibility with other bars
        return hide
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    // MARK: actions
    @IBAction func onClickAction(sender: AnyObject) {
        if (preparedZipURL == nil) {
            return
        }
        let activityVC = UIActivityViewController(activityItems: [preparedZipURL!], applicationActivities: [])
        presentViewController(activityVC, animated: true, completion: {})
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        
    }
    
    // MARK: PHLivePhotoViewDelegate
    func livePhotoView(livePhotoView: PHLivePhotoView, willBeginPlaybackWithStyle playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // check if the live photo starts playing
        if (playbackStyle == PHLivePhotoViewPlaybackStyle.Full) {
            // save current bar visibility
            barsHidden = self.navigationController?.navigationBarHidden
            
            hideBars()
        }
    }
    
    func livePhotoView(livePhotoView: PHLivePhotoView, didEndPlaybackWithStyle playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // check if the live photo stops playing
        if (playbackStyle == PHLivePhotoViewPlaybackStyle.Full) {
            // recover only if bars were visible before playing
            if (!barsHidden) {
                unhideBars()
            }
        }
    }
    
    func hideBars() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func unhideBars() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func targetSize() -> CGSize {
        let scale = UIScreen.mainScreen().scale
        let output = CGSizeMake(CGRectGetWidth(liveImg_photo.bounds) * scale, CGRectGetHeight(liveImg_photo.bounds) * scale)
        return output
    }
    
    func cleanup() {
        // if zip file exists, remove it
        if (preparedZipURL != nil) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(preparedZipURL!.relativePath!)
                preparedZipURL = nil
            } catch let error {
                NSLog(String(error))
            }
        }
        
        // if video files exists, remove it
        if (videoURL != nil) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(videoURL!.relativePath!)
                videoURL = nil
            } catch let error {
                NSLog(String(error))
            }
        }
    }
    
    func prepareZip(entries: [ZZArchiveEntry]) {
        // create zip file
        let zipName = universalFileName + ".zip"
        let zipURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(zipName))
        var newArchive: ZZArchive?
        do {
            newArchive = try ZZArchive(URL: zipURL, options: [ZZOpenOptionsCreateIfMissingKey: true])
            preparedZipURL = zipURL
        } catch let error {
            NSLog(String(error))
            return
        }
        
        // add entries to zip file
        do {
            try newArchive!.updateEntries(entries)
        } catch let error{
            NSLog(String(error))
            return
        }
    }
    
    func prepareZipEntries() {
        var imageEntry: ZZArchiveEntry? = nil
        var videoEntry: ZZArchiveEntry? = nil
        
        // save image
        let imageName = universalFileName + ".jpg"
        let imageURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(imageName))
        PHAssetResourceManager.defaultManager().writeDataForAssetResource(assetResource[0], toFile: imageURL, options: nil, completionHandler: {(error: NSError?) in
            // construct image archive entry
            imageEntry = ZZArchiveEntry(fileName: imageName, compress: true, dataBlock: { (error: NSErrorPointer) -> NSData? in
                // get image data
                let imageData = NSData(contentsOfURL: imageURL)
                
                // remove image file
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(imageURL.relativePath!)
                } catch let error {
                    NSLog(String(error))
                }
                
                return imageData
            })
            
            if (videoEntry != nil) {
                self.prepareZip([imageEntry!,videoEntry!])
            }
        })
        
        // save video
        let videoName = universalFileName + ".mov"
        videoURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(videoName))
        PHAssetResourceManager.defaultManager().writeDataForAssetResource(assetResource[1], toFile: videoURL!, options: nil, completionHandler: {(error: NSError?) in
            // create video archive entry
            videoEntry = ZZArchiveEntry(fileName: videoName, compress: true, dataBlock: { (error: NSErrorPointer) -> NSData? in
                // get video data
                let videoData = NSData(contentsOfURL: self.videoURL!)
                
                // we do not delete video at this point as it may get exported later
                
                return videoData
            })
            
            if (imageEntry != nil) {
                self.prepareZip([imageEntry!,videoEntry!])
            }
        })
    }
    
    func updateImage() {
        // lastTargetSize = targetSize
        
        // prepare the options to pass when fetching live photo
        let photoRequestOptions = PHLivePhotoRequestOptions()
        photoRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        photoRequestOptions.networkAccessAllowed = true
        photoRequestOptions.progressHandler = {(progress: Double, error: NSError?, stop: UnsafeMutablePointer<ObjCBool>, info: [NSObject : AnyObject]?) in
            dispatch_async(dispatch_get_main_queue(), {() in
                self.progress_load.progress = Float(progress)
            })
        }
        
        // request the live photo for the asset from the default PHImageManager
        PHImageManager.defaultManager().requestLivePhotoForAsset(asset, targetSize: targetSize(), contentMode: PHImageContentMode.AspectFit, options: photoRequestOptions) {(livePhoto: PHLivePhoto?, info: [NSObject : AnyObject]?) in
            // hide the progress bar
            self.progress_load.hidden = true
            
            // show live photo
            self.assetResource = PHAssetResource.assetResourcesForLivePhoto(livePhoto!)
            self.liveImg_photo.livePhoto = livePhoto
            
            // prepare zip file
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.prepareZipEntries()
                
                // if VC is not visible, clean up
                if (!(self.isViewLoaded()) || self.view.window == nil) {
                    self.cleanup()
                }
            })
            
        }
        
        //        // prepare PHContentEditingInputRequestOptions
        //        let contentEditingOptions = PHContentEditingInputRequestOptions()
        //        contentEditingOptions.networkAccessAllowed = true
        //
        //        // request ContentEditingInput
        //        asset.requestContentEditingInputWithOptions(contentEditingOptions, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [NSObject : AnyObject]) in
        //            let image = CIImage(contentsOfURL: contentEditingInput!.fullSizeImageURL!)!
        //
        //
        //        })
    }
    
    /*func showVideoSavedHUD() {
        // construct HUD
        hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud!.mode = MBProgressHUDMode.CustomView
        hud!.label.text = "Saved"
        
        // add icon
        let icon = UIImage(named: "HudIconDone")
        hud!.customView = UIImageView(image: icon)
        
        // Looks a bit nicer if we make it square.
        hud!.square = true;
        
        // automatically dismissed after 2 seconds
        hud!.hideAnimated(true, afterDelay: 2.0)
        
        // add a gesture recoginer to dismiss the overlay on any tap
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoDetailsVC.onTapAnywhere))
        hud!.addGestureRecognizer(gestureRecognizer)
    }
    
    func onTapAnywhere(gestureRecognizer: UIGestureRecognizer) {
        if (hud != nil) {
            hud!.hideAnimated(true)
        }
    }*/
}
