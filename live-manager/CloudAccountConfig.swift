//
//  CloudAccountConfig.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-11.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation

class CloudAccountConfig: NSObject, NSCoding {
    var serviceProviderName: String
    var autoUpload: Bool
    
    init(serviceProviderName: String) {
        self.serviceProviderName = serviceProviderName
        autoUpload = false
    }
    
    required init?(coder decoder: NSCoder) {
        serviceProviderName = decoder.decodeObjectForKey("serviceProviderName") as! String
        autoUpload = decoder.decodeObjectForKey("autoUpload") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(serviceProviderName, forKey: "serviceProviderName")
        aCoder.encodeObject(autoUpload, forKey: "autoUpload")
    }
    
}
