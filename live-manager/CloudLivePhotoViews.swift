//
//  CloudLivePhotoViews.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-20.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class CloudAccountTableCell: UITableViewCell {
    @IBOutlet weak var image_icon: UIImageView!
    @IBOutlet weak var label_userName: UILabel!
    
    var serviceProvider: CloudServiceProvider?
    
    // for SettingsVC only
    var accountConfig: CloudAccountConfig?
}

class CloudServiceTableCell: UITableViewCell {
    @IBOutlet weak var image_logo: UIImageView!
    
    var serviceProvider: CloudServiceProvider?
}

class LivePhotoListCell: UITableViewCell {
    @IBOutlet weak var collection_master: CloudLivePhotoCollection!
}

class CloudLivePhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var image_thumbnail: UIImageView!
    
    var myCloudLivePhoto: CloudLivePhoto!
    
    func loadImageView(myCloudLivePhoto: CloudLivePhoto) {
        self.myCloudLivePhoto = myCloudLivePhoto
        
        let thumbnailURL = myCloudLivePhoto.thumbnailURL
        if NSFileManager.defaultManager().fileExistsAtPath(thumbnailURL.path!) {
             image_thumbnail.image = UIImage(data: NSData(contentsOfURL: myCloudLivePhoto.thumbnailURL)!)
        } else {
            CloudDataManager.downloadCloudLivePhotoThumbnail(myCloudLivePhoto.photoFileMetaData, thumbnailURL: thumbnailURL, completion: {() in
                self.image_thumbnail.image = UIImage(data: NSData(contentsOfURL: thumbnailURL)!)
                }
            )
        }
    }
}

class ViewMoreTableCell: UITableViewCell {
    
}

class CloudFolderTableCell: UITableViewCell {
    
}
