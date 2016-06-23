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

class CloudLivePhotoCollection: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    private let CELL_REUSE_ID_CLOUD_LIVE_PHOTO_THUMB_CELL = "cloudLivePhotoThumbCell"
    
    var cloudLivePhotos: [CloudLivePhoto]?
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let livePhotoCount = cloudLivePhotos!.count
        return livePhotoCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoThumbnailCell = self.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_ID_CLOUD_LIVE_PHOTO_THUMB_CELL, forIndexPath: indexPath) as! CloudLivePhotoCollectionCell
        photoThumbnailCell.loadImageView(cloudLivePhotos![indexPath.item])
        return photoThumbnailCell
    }
    
}

class CloudLivePhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var image_thumbnail: UIImageView!
    
    func loadImageView(myCloudLivePhoto: CloudLivePhoto) {
        let thumbnailURL = myCloudLivePhoto.thumbnailURL
        if NSFileManager.defaultManager().fileExistsAtPath(thumbnailURL.path!) {
             image_thumbnail.image = UIImage(data: NSData(contentsOfURL: myCloudLivePhoto.thumbnailURL)!)
        } else {
            CloudDataManager.getCloudLivePhotoThumbnail(myCloudLivePhoto.photoFileMetaData, thumbnailURL: thumbnailURL, completion: {() in
                self.image_thumbnail.image = UIImage(data: NSData(contentsOfURL: myCloudLivePhoto.thumbnailURL)!)
                }
            )
        }
    }
}

class ViewMoreTableCell: UITableViewCell {
    
}

class CloudFolderTableCell: UITableViewCell {
    
}
