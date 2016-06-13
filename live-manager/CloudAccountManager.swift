//
//  CloudAccountManager.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-12.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation
import SwiftyDropbox

let USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS = "cloudAccConfigs"

let NOTIFICATION_NAME_CLOUD_ACC_UPDATED = "cloudAccUpdated"

let CLOUD_SERVICES_NUM = 3 // total number of cloud services available

enum CloudServiceProvider: String {
    case Dropbox  = "Dropbox"
    case GDrive   = "Google Dirve"
    case OneDrive = "OneDrive"
    
    static let allValues = [Dropbox, GDrive, OneDrive]
}

class CloudAccountManager {
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    private static var cloudAccCheckedNum = 0
    static var reloading = false
    
    init() {
        CloudAccountManager.reload()
    }
    
    static func getCloudAccountCell(tableView: UITableView, accConfig: CloudAccountConfig) -> CloudAccountTableCell{
        let cloudAccountCell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_ACC) as! CloudAccountTableCell
        let serviceProvider = CloudServiceProvider(rawValue: accConfig.serviceProviderName)!
        
        // set icon
        switch (serviceProvider) {
        case .Dropbox:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_DROPBOX_ICON)
            break
        case .GDrive:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_GDRIVE_ICON)
            break
        case .OneDrive:
            cloudAccountCell.image_icon.image = UIImage(named: IMAGE_NAME_ONEDRIVE_ICON)
            break
        }
        
        cloudAccountCell.label_userName.text = accConfig.userName
        
        cloudAccountCell.serviceProvider = serviceProvider
        
        return cloudAccountCell
    }
    
    static func getCloudServiceCell(tableView: UITableView, serviceProvider: CloudServiceProvider) -> CloudServiceTableCell {
        let cloudServiceCell = tableView.dequeueReusableCellWithIdentifier(CELL_REUSE_ID_CLOUD_SERVICE) as! CloudServiceTableCell
        
        // set image
        switch (serviceProvider) {
        case .Dropbox:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_DROPBOX_LOGO)
            break
        case .GDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_GDRIVE_LOGO)
            break
        case .OneDrive:
            cloudServiceCell.image_logo.image = UIImage(named: IMAGE_NAME_ONEDRIVE_LOGO)
            break
        }
        
        cloudServiceCell.serviceProvider = serviceProvider
        
        return cloudServiceCell
    }
    
    private static func reload() {
        cloudAccCheckedNum = 0
        reloading = true
        
        // check all services
        for cloudServiceProvider in CloudServiceProvider.allValues {
            checkAccount(cloudServiceProvider)
        }
    }
    
    static func getAvailableCloudServices() -> [CloudServiceProvider] {
        var availableCoudServices = CloudServiceProvider.allValues
        
        if let encodedAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // userDefaults file exists
            
            for (index, avaliableCloudService) in availableCoudServices.enumerate() {
                // search for desired CloudAccConfig
                let cloudServiceIndex = CloudAccountManager.indexOf(avaliableCloudService.rawValue, encodedAccConfigs: encodedAccConfigs)
                
                if cloudServiceIndex != -1 { // configuration found
                    availableCoudServices.removeAtIndex(index)
                }
            }
        }
        return availableCoudServices
    }
    
    static func getDecodedAccConfigs() -> [CloudAccountConfig] {
        if let encodedAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // userDefaults file exists
            var decodedAccConfigs = [CloudAccountConfig]()
            
            // search for existing CloudAccConfig
            for encodedAccConfig in encodedAccConfigs {
                if let decodedAccConfig = NSKeyedUnarchiver.unarchiveObjectWithData(encodedAccConfig) as? CloudAccountConfig {
                    decodedAccConfigs.append(decodedAccConfig)
                }
            }
            
            return decodedAccConfigs
        } else {
            // create file
            userDefaults.setObject([NSData](), forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
            
            return []
        }
    }
    
    static func unlinkAccount(serviceProviderName: String) {
        // call API
        switch (CloudServiceProvider(rawValue: serviceProviderName)!) {
        case .Dropbox:
            Dropbox.unlinkClient()
            break
        case .GDrive:
            break
        case .OneDrive:
            break
        }
        
        // remove config file
        CloudAccountManager.removeAccConfig(serviceProviderName)
    }
    
    private static func checkAccount(serviceProvider: CloudServiceProvider) {
        switch (serviceProvider) {
        case .Dropbox:
            if let client = Dropbox.authorizedClient {
                // Get the current user's account info
                client.users.getCurrentAccount().response { response, error in
                    if let account = response { // success
                        if readAccConfig(serviceProvider) == nil { // config doesn't exist
                            writeAccConfig(CloudAccountConfig(serviceProviderName: CloudServiceProvider.Dropbox.rawValue, userName: account.name.displayName))
                        }
                        cloudAccCheckced()
                    } else {
                        print(error!)
                        cloudAccCheckced()
                    }
                }
            } else {
                cloudAccCheckced()
            }
            break
        case .GDrive:
            cloudAccCheckced()
            break
        case .OneDrive:
            cloudAccCheckced()
            break
        }
    }
    
    private static func cloudAccCheckced() {
        cloudAccCheckedNum += 1
        
        // refresh tableView if all accounts have been checked
        if (cloudAccCheckedNum == CLOUD_SERVICES_NUM) {
            reloading = false
            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_NAME_CLOUD_ACC_UPDATED, object: nil)
        }
    }
    
    private static func readAccConfig(serviceProvider: CloudServiceProvider) -> CloudAccountConfig? {
        if let encodedAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // userDefaults file exists
            
            // search for existing CloudAccConfig
            for encodedAccConfig in encodedAccConfigs {
                if let accConfig = NSKeyedUnarchiver.unarchiveObjectWithData(encodedAccConfig) as? CloudAccountConfig {
                    if accConfig.serviceProviderName == serviceProvider.rawValue {
                        return accConfig
                    }
                }
            }
            
            // No existing CloudAccConfig
            return nil
        } else {
            // create file
            userDefaults.setObject([NSData](), forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
            
            return nil
        }
    }
    
    static func writeAccConfig(newAccConfig: CloudAccountConfig) {
        let encodedNewAccConfig =  NSKeyedArchiver.archivedDataWithRootObject(newAccConfig)
        
        if var encodedAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // userDefaults file exists
            
            // search for existing CloudAccConfig
            let updateIndex = CloudAccountManager.indexOf(newAccConfig.serviceProviderName, encodedAccConfigs: encodedAccConfigs)
            
            if updateIndex == -1 { // no existing config, append new one
                encodedAccConfigs.append(encodedNewAccConfig)
            } else { // make change on existing config
                encodedAccConfigs[updateIndex] = encodedNewAccConfig
            }
            
            // write to userDefaults
            userDefaults.setObject(encodedAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
        } else {
            // create file with newAccConfig
            userDefaults.setObject([encodedNewAccConfig], forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_NAME_CLOUD_ACC_UPDATED, object: nil)
    }
    
    private static func removeAccConfig(serviceProviderName: String) {
        if var encodedAccConfigs = userDefaults.objectForKey(USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS) as? [NSData] { // userDefaults file exists
            
            // search for desired CloudAccConfig
            let removeIndex = CloudAccountManager.indexOf(serviceProviderName, encodedAccConfigs: encodedAccConfigs)
            
            if removeIndex != 1 { // configuration found
                encodedAccConfigs.removeAtIndex(removeIndex)
                
                // write to userDefaults
                userDefaults.setObject(encodedAccConfigs, forKey: USER_DEFAULTS_KEY_CLOUD_ACC_CONFIGS)
                
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_NAME_CLOUD_ACC_UPDATED, object: nil)
            }
            
            
        }
    }
    
    private static func indexOf(serviceProviderName: String, encodedAccConfigs: [NSData]) -> Int{
        var resultIndex = -1
        for (index, encodedAccConfig) in encodedAccConfigs.enumerate() {
            if let accConfig = NSKeyedUnarchiver.unarchiveObjectWithData(encodedAccConfig) as? CloudAccountConfig {
                if accConfig.serviceProviderName == serviceProviderName {
                    resultIndex = index
                    break
                }
            }
        }
        return resultIndex
    }
}