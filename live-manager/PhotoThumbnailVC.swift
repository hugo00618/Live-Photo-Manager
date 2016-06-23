//
//  PhotoThumbnailVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-04-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import Photos

class PhotoThumbnailVC: UICollectionViewController, PHPhotoLibraryChangeObserver {
    let REUSE_ID_PHOTO_CELL = "PhotoCell"
    let REUSE_ID_SHOT_DATE_HEADER = "ShotDateHeader"
    let REUSE_ID_MY_FOOTER = "myFooter"
    
    let SEGUE_ID_SHOW_PHOTO_DETAILS = "ShowPhotoDetails"
    
    
    var myFetchResult: PHFetchResult!
    var assetsByDate = [[PHAsset]]()
    var formattedCreationDates = [String]()
    
    var imageManager: PHCachingImageManager!
    var previousPreheatRect: CGRect!
    var assetGridThumbnailSize: CGSize!
    
    @IBOutlet weak var collection_photos: UICollectionView!
    
    override func awakeFromNib() {
        // init imageManager
        imageManager = PHCachingImageManager()
        //resetCachedAssets()
        
        // fetch live photos
        fetchLivePhotos()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return assetsByDate.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsByDate[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myAsset = assetsByDate[indexPath.section][indexPath.row]
        
        // load reused cell
        let myCell = collection_photos.dequeueReusableCellWithReuseIdentifier(REUSE_ID_PHOTO_CELL, forIndexPath: indexPath) as! PhotoThumbnailCell
        
        // set thumbnail image of cell
        self.imageManager.requestImageForAsset(myAsset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFit, options: PHImageRequestOptions(), resultHandler: {(result: UIImage?, info: [NSObject : AnyObject]?) in
            myCell.img_thumbnail.image = result
        })
        
        return myCell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: REUSE_ID_SHOT_DATE_HEADER, forIndexPath: indexPath) as! PhotoShotDateHeader
            
            header.label_master.text = formattedCreationDates[indexPath.section]
            
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == SEGUE_ID_SHOW_PHOTO_DETAILS) {
            // get destination VC
            let myPhotoDetailsVC = segue.destinationViewController as! PhotoDetailsVC
            
            // hide myPhotoDetailsVC's tab bar
            myPhotoDetailsVC.hidesBottomBarWhenPushed = true
            
            // pass asset to myPhotoDetailsVC
            if let myIndexPath = collection_photos.indexPathForCell(sender as! UICollectionViewCell) {
                myPhotoDetailsVC.asset = assetsByDate[myIndexPath.section][myIndexPath.row]
            }
            
            //
            (self.collectionViewLayout as! MyStickyHeaderFlowLayout).disableInvalidateCount = 5
        }
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        let changeDetails = changeInstance.changeDetailsForFetchResult(myFetchResult)
        
        // check if there are changes to assets, update myFetchResult and reload collection view
        if (changeDetails != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                self.myFetchResult = changeDetails?.fetchResultAfterChanges
                self.loadAssetsByDate()
                self.collection_photos.reloadData()
            })
        }
        
        // check if there is no live photos
        if (myFetchResult.count == 0) {
            
        } else {
            
        }
        
        //resetCachedAssets()
    }
    
    // MARK: UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //updateCachedAssets()
    }
    
    func loadFetchResult() {
        let livePhotosFetchOptions = PHFetchOptions()
        livePhotosFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        livePhotosFetchOptions.predicate = NSPredicate(format: "mediaSubtype == %ld", PHAssetMediaSubtype.PhotoLive.rawValue)
        myFetchResult = PHAsset.fetchAssetsWithOptions(livePhotosFetchOptions)
    }
    
    func loadAssetsByDate() {
        assetsByDate = [[PHAsset]]()
        
        var currentCreationDate = NSDate(timeIntervalSince1970: 0)
        var currentDateAssets = [PHAsset]()
        myFetchResult.enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if let asset = obj as? PHAsset {
                if NSCalendar.currentCalendar().isDate(asset.creationDate!, inSameDayAsDate: currentCreationDate) { // creation dates match, continue to add to currentDateAssests
                    currentDateAssets.append(asset)
                } else { // creation dates don't match
                    if currentDateAssets.count > 0 { // append currentDateAsssets to assetsByDate if not empty
                        self.assetsByDate.append(currentDateAssets)
                        self.formattedCreationDates.append(DateUtility.formattedHumanReadable(currentCreationDate))
                    }
                    
                    // declare new dateAssets
                    currentCreationDate = asset.creationDate!
                    currentDateAssets = [asset]
                }
            }
        }
        // append the currentDateAssets if not empty
        if (currentDateAssets.count > 0) {
            self.assetsByDate.append(currentDateAssets)
            self.formattedCreationDates.append(DateUtility.formattedHumanReadable(currentCreationDate))
        }
    }
    
    func fetchLivePhotos() {
        loadFetchResult()
        loadAssetsByDate()
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
