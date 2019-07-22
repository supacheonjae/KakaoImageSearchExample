//
//  DateConverter.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation

class DateConverter {
    
    static let shared = DateConverter()
    
    private let iso8601Formatter = ISO8601DateFormatter()
    
    private init() {
        //[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss].000+[tz]
        iso8601Formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
    }
    
    func iso8601Date(from: String) -> Date? {
        return iso8601Formatter.date(from: from)
    }
    
    func iso8601String(from: Date) -> String {
        return iso8601Formatter.string(from: from)
    }
}
