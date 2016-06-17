//
//  DateUtility.swift
//  live-manager
//
//  Created by Hugo Yu on 2016-06-17.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation

class DateUtility {
    
    static func formattedHumanReadable(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .MediumStyle
        formatter.doesRelativeDateFormatting = true
        
        let locale = NSLocale.currentLocale()
        formatter.locale = locale
        
        return formatter.stringFromDate(date)
    }
    
}