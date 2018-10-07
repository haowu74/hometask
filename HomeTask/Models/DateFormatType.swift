//
//  DateFormatType.swift
//  HomeTask
//
//  Created by Hao Wu on 7/10/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation

/// Date Format type
enum DateFormatType: String {
    /// Time
    case time = "HH:mm:ss"
    
    /// Date with hours
    case dateWithTime = "yyyy-MM-dd HH:mm:ss"
    
    /// Date
    case date = "yyyy-MM-dd"
}
