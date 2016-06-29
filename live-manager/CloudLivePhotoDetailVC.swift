//
//  CloudLivePhotoDetailVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-29.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class CloudLivePhotoDetailVC: UIViewController {
    
    @IBOutlet weak var image_stillPhoto: UIImageView!
    var hud: MBProgressHUD?
    
    var myCloudLivePhoto: CloudLivePhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set thumbnail as preview
        image_stillPhoto.image = UIImage(data: NSData(contentsOfURL: myCloudLivePhoto.thumbnailURL)!)
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // load live photo
        
    }
    
    func loadLivePhoto() {
        
    }
}
