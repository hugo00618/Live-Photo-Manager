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
    
    static func getFileList(serviceProvider: CloudServiceProvider, path: String, completion: (livePhotos: [PHLivePhoto], dirs: [Files.Metadata]) -> Void) {
        var livePhotos: [PHLivePhoto] = []
        var dirs: [Files.FolderMetadata] = []
        
        switch serviceProvider {
        case .Dropbox:
            if let client = Dropbox.authorizedClient {
                client.files.listFolder(path: path).response { response, error in
                    if let result = response {
                        var livePhotoJpegEntry: Files.Metadata? = nil
                        for entry in result.entries {
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
                        
                        completion(livePhotos: livePhotos, dirs: dirs)
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
}
