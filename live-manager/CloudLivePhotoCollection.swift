//
//  CloudLivePhotoCollection.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-29.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

protocol CloudLivePhotoCollectionProtocol {
    func didSelectItem(myCloudLivePhoto: CloudLivePhoto)
}

class CloudLivePhotoCollection: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    private let CELL_REUSE_ID_CLOUD_LIVE_PHOTO_THUMB_CELL = "cloudLivePhotoThumbCell"
    
    var myProtocol: CloudLivePhotoCollectionProtocol?
    
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! CloudLivePhotoCollectionCell
        myProtocol?.didSelectItem(selectedCell.myCloudLivePhoto)
    }
    
}