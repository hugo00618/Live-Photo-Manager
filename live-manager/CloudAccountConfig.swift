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
    var userName: String
    var autoUpload: Bool
    
    init(serviceProviderName: String, userName: String) {
        self.serviceProviderName = serviceProviderName
        self.userName = userName
        autoUpload = false
    }
    
    required init?(coder decoder: NSCoder) {
        serviceProviderName = decoder.decodeObjectForKey("serviceProviderName") as! String
        userName = decoder.decodeObjectForKey("userName") as! String
        autoUpload = decoder.decodeObjectForKey("autoUpload") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(serviceProviderName, forKey: "serviceProviderName")
        aCoder.encodeObject(userName, forKey: "userName")
        aCoder.encodeObject(autoUpload, forKey: "autoUpload")
    }
    
}
