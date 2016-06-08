//
//  FileUnsupportedVC.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-07.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class FileUnsupportedVC: UIViewController {

    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
