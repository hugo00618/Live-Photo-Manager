//
//  PhotoThumbnailVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import Photos

let photoCellReuseId = "PhotoCell"
let showPhotoDetailsSegueId = "ShowPhotoDetails"

class PhotoThumbnailVC: UICollectionViewController, PHPhotoLibraryChangeObserver {
    
    var fetchResult: PHFetchResult!
    var imageManager: PHCachingImageManager!
    var previousPreheatRect: CGRect!
    var assetGridThumbnailSize: CGSize!
    
    @IBOutlet weak var collection_photos: UICollectionView!
    
    override func awakeFromNib() {
        // init imageManager
        imageManager = PHCachingImageManager()
        //resetCachedAssets()
        
        // fetch live photos
        let livePhotosFetchOptions = PHFetchOptions()
        livePhotosFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        livePhotosFetchOptions.predicate = NSPredicate(format: "mediaSubtype == %ld", PHAssetMediaSubtype.PhotoLive.rawValue)
        fetchResult = PHAsset.fetchAssetsWithOptions(livePhotosFetchOptions)
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UIViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide toolbar, undo hide bars on tap
        self.navigationController?.toolbarHidden = true
        self.navigationController?.hidesBarsOnTap = false
        
        // determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.mainScreen().scale
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //updateCachedAssets()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == showPhotoDetailsSegueId) {
            // get destination VC
            let myPhotoDetailsVC = segue.destinationViewController as! PhotoDetailsVC
            
            // hide myPhotoDetailsVC's tab bar
            myPhotoDetailsVC.hidesBottomBarWhenPushed = true
            
            // pass asset to myPhotoDetailsVC
            let myIndexPath = collection_photos.indexPathForCell(sender as! UICollectionViewCell)
            myPhotoDetailsVC.asset = fetchResult[myIndexPath!.item] as! PHAsset
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myAsset = fetchResult[indexPath.item] as! PHAsset
        
        // load reused cell
        let myCell = collection_photos.dequeueReusableCellWithReuseIdentifier(photoCellReuseId, forIndexPath: indexPath) as! PhotoThumbnailCell
        
        // prepare request image options to get cropped image
        let requestImageOptions = PHImageRequestOptions()
        requestImageOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        let cropSideLength = CGFloat(min(myAsset.pixelWidth, myAsset.pixelHeight))
        let cropRect = CGRectApplyAffineTransform(CGRectMake(0, 0, cropSideLength, cropSideLength), CGAffineTransformMakeScale(1.0 / CGFloat(myAsset.pixelWidth), 1.0 / CGFloat(myAsset.pixelHeight)))
        requestImageOptions.normalizedCropRect = cropRect
        
        // set thumbnail image of cell
        self.imageManager.requestImageForAsset(myAsset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFit, options: requestImageOptions, resultHandler: {(result: UIImage?, info: [NSObject : AnyObject]?) in
            myCell.img_thumbnail.image = result
            })
        
        return myCell
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        let changeDetails = changeInstance.changeDetailsForFetchResult(fetchResult)
        
        // check if there are changes to assets, update myFetchResult and reload collection view
        if (changeDetails != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.fetchResult = changeDetails?.fetchResultAfterChanges
                self.collection_photos.reloadData()
            })
        }
        
        // check if there is no live photos
        if (fetchResult.count == 0) {
            
        } else {
            
        }
        
        //resetCachedAssets()
    }
    
    // MARK: UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //updateCachedAssets()
    }
    
    
    /*func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRectZero
    }
    
    func updateCachedAssets() {
        let isViewVisible = isViewLoaded() && self.view.window != nil
        if (!isViewVisible) {
            return
        }
        
        // preheat content
        var preheatRect = collection_photos.bounds
        preheatRect = CGRectInset(preheatRect, 0, -0.5 * CGRectGetHeight(preheatRect))
        
        // check if the collection view is showing an area that is significantly different to the last preheated area.
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect))
        if (delta > CGRectGetHeight(collection_photos.bounds) / 3.0) {
            // compute assets to start caching and to stop caching
            var addedIndexPaths = []
            var removedIndexPaths = []
            
            computeDifferenceBetweenRect(preheatRect, newRect: preheatRect, removedHandler: { (removedRect) in
                var indexPaths = collection_photos
                }, addedHandler: <#T##(addedRect: CGRect) -> Void#>)
        }
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, newRect: CGRect, removedHandler:(removedRect: CGRect)->Void, addedHandler: (addedRect: CGRect)->Void) {
        
    }*/

    
    
}
