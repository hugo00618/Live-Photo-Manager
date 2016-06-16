//
//  MyStickyHeaderFlowLayout.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-15.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit
import CSStickyHeaderFlowLayout

class MyStickyHeaderFlowLayout: CSStickyHeaderFlowLayout {
    var disableInvalidateCount = 0
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if (disableInvalidateCount > 0) {
            disableInvalidateCount -= 1
            return false
        }
        
        return true
    }
    
}
