//
//  CloudDataManager.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-16.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation
import SwiftyDropbox
import Photos
import PhotosUI

class CloudDataManager {
    
    static func getFileList(serviceProvider: CloudServiceProvider, path: String, completion: (cloudLivePhotos: [CloudLivePhoto], dirs: [Files.Metadata]) -> Void) {
        var cloudLivePhotos: [CloudLivePhoto] = []
        var dirs: [Files.FolderMetadata] = []
        
        switch serviceProvider {
        case .Dropbox:
            if let client = Dropbox.authorizedClient {
                client.files.listFolder(path: path).response { response, error in
                    if let result = response {
                        var livePhotoJpegEntry: Files.Metadata? = nil
                        
                        // sort entires based on their names
                        var entries = result.entries
                        entries.sortInPlace({ (metaData1, metaData2) -> Bool in
                            return metaData1.name.caseInsensitiveCompare(metaData2.name) == NSComparisonResult.OrderedAscending
                        })
                        
                        for entry in entries {
                            let entryName = entry.name
                            if let folderEntry = entry as? Files.FolderMetadata { // folder
                                dirs.append(folderEntry)
                            } else { // file
                                // check file type
                                if (LivePhotoFileUtility.entryIsJPEG(entryName)) { // jpeg
                                    // possible live photo still image, save it and look for corresponding mov
                                    livePhotoJpegEntry = entry
                                } else if (LivePhotoFileUtility.entryIsMOV(entryName) && livePhotoJpegEntry != nil) { // mov
                                    // check if mov matches jpeg name
                                    if (LivePhotoFileUtility.removeExtension(livePhotoJpegEntry!.name) == LivePhotoFileUtility.removeExtension(entryName)) { // names match
                                        let thumbnailURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("/Dropbox/" + livePhotoJpegEntry!.pathLower + "thumb"))
                                        
                                        try! NSFileManager.defaultManager().createDirectoryAtURL(thumbnailURL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
                                        
                                        cloudLivePhotos.append(CloudLivePhoto(thumbnailURL: thumbnailURL, photoFileMetaData:
                                            livePhotoJpegEntry!, videoFileMetaData: entry))
                                    } else { // no need to find current jpeg's video any more since they should be together if they have the same name
                                        livePhotoJpegEntry = nil
                                    }
                                } else if (LivePhotoFileUtility.entryIsZip(entryName)) { // zip
                                    
                                }
                                
                            }
                        }
                        
                        // sort dirs by folder name in ascending order
                        dirs.sortInPlace({ (metaData1, metaData2) -> Bool in
                            return metaData1.name.caseInsensitiveCompare(metaData2.name) == NSComparisonResult.OrderedAscending
                        })
                        
                        completion(cloudLivePhotos: cloudLivePhotos, dirs: dirs)
                    } else {
                        print(error!)
                    }
                }
            }
            break
        case .GDrive:
            break
        case .OneDrive:
            break
        }
    }
    
    static func downloadCloudLivePhotoThumbnail(metaData: Files.Metadata, thumbnailURL: NSURL, completion: () -> Void) {
        if let client = Dropbox.authorizedClient {
            let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                return thumbnailURL
            }
            
            client.files.getThumbnail(path: metaData.pathLower, format: Files.ThumbnailFormat.Jpeg, size: Files.ThumbnailSize.W640h480, destination: destination).response {
                response, error in
                completion()
            }
        }
    }
    
    static func downloadFile() {
        if let client = Dropbox.authorizedClient {
            let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                let fileManager = NSFileManager.defaultManager()
                let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                // generate a unique name for this file in case we've seen it before
                let UUID = NSUUID().UUIDString
                let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
            }
            
            client.files.download(path: "/hello.txt", destination: destination).response { response, error in
                if let (metadata, url) = response {
                    let data = NSData(contentsOfURL: url)
                } else {
                    print(error!)
                }
            }
        }
    }
}
