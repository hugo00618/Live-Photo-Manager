//
//  SaveVideoActivity.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-15.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class SaveVideoActivity: UIActivity {
    
    var videoURL: NSURL
    var parentVC: PhotoDetailsVC
    
    init(videoURL: NSURL, parentVC: PhotoDetailsVC) {
        self.videoURL = videoURL
        self.parentVC = parentVC
    }
    
    // MARK: UIActivity
    override func activityTitle() -> String? {
        return "Export as Video"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "ActIcon_SaveVideo")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            UISaveVideoAtPathToSavedPhotosAlbum(self.videoURL.relativePath!, self, #selector(self.didFinishSaving), nil)
        })
    }
    
    func didFinishSaving(videoPath: String, error: NSError?, contextInfo: UnsafeMutablePointer<Void>) {
        if (error == nil) { // saved successfully
            parentVC.showVideoSavedHUD()
        } else { // failed to save
            NSLog(String(error))
        }
    }
    
    func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Share
    }
}
