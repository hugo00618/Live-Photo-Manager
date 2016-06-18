//
//  FullScreenImagePrompt.swift
//  iOS Test
//
//  Created by Hugo Yu on 2016-06-18.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class FullScreenImagePrompt: UIView {

    @IBOutlet var view: UIView!

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_content: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("FullScreenImagePrompt", owner: self, options: nil)
        self.bounds = self.view.bounds
        
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("FullScreenImagePrompt", owner: self, options: nil)
        self.addSubview(view)
    }

}
