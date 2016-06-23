//
//  CloudLivePhoto.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-20.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation
import SwiftyDropbox

class CloudLivePhoto {
    
    var thumbnailURL: NSURL
    var photoFileMetaData: Files.Metadata
    var videoFileMetaData: Files.Metadata
    
    init(thumbnailURL: NSURL, photoFileMetaData: Files.Metadata, videoFileMetaData: Files.Metadata) {
        self.thumbnailURL = thumbnailURL
        self.photoFileMetaData = photoFileMetaData
        self.videoFileMetaData = videoFileMetaData
    }
    
}