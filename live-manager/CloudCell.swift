//
//  CloudCell.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-10.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class CloudAccountTableCell: UITableViewCell {
    @IBOutlet weak var image_icon: UIImageView!
    @IBOutlet weak var label_userName: UILabel!
    
    var serviceProvider: CloudServiceProvider?
    
    // for SettingsVC only
    var accountConfig: CloudAccountConfig?
}

class CloudServiceTableCell: UITableViewCell {
    @IBOutlet weak var image_logo: UIImageView!
    
    var serviceProvider: CloudServiceProvider?
}

class LivePhotoListCell: UITableViewCell {
    @IBOutlet weak var collection_master: UICollectionView!
}
