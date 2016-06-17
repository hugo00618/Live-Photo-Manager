//
//  LivePhotoFileUtility.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-17.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation

class LivePhotoFileUtility {
    // unzipLivePhoto() consumes the URL of the zip file and returns an array of NSURL's where the first URL is still photo and the second URL is video, or returns nil if fails
    static func unzipLivePhoto(zipURL: NSURL) -> [NSURL]? {
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
    static func entriesAreOfCorrectType(firstName: String, secondName: String) -> Bool {
        return entryIsJPEG(firstName) && entryIsMOV(secondName)
    }
    
    static func entryIsJPEG(fileName: String) -> Bool {
        return fileName.hasSuffix(".jpg") || fileName.hasSuffix(".JPG") || fileName.hasSuffix(".jpeg") || fileName.hasSuffix(".JPEG")
    }
    
    static func entryIsMOV(fileName: String) -> Bool {
        return fileName.hasSuffix(".mov") || fileName.hasSuffix(".MOV")
    }
    
    static func entryIsZip(fileName: String) -> Bool {
        return fileName.hasSuffix(".zip") || fileName.hasSuffix(".ZIP")
    }
    
    static func removeExtension(fileName: String) -> String {
        return fileName.substringToIndex(fileName.rangeOfString(".")!.startIndex)
    }
}