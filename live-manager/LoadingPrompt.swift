//
//  LoadingPrompt.swift
//  iOS Test
//
//  Created by Hugo Yu on 2016-06-18.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class LoadingPrompt: UIView {

    @IBOutlet var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("LoadingPrompt", owner: self, options: nil)
        self.bounds = self.view.bounds
        
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("LoadingPrompt", owner: self, options: nil)
        self.addSubview(view)
    }

}
