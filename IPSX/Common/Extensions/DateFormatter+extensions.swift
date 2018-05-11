//
//  DateFormatter+extensions.swift
//  IPSX
//
//  Created by Calin Chitu on 11/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

extension DateFormatter {
    
    class func backendResponseParse() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
    
    class func secondsToDaysHoursMinutes(seconds : Int) -> (Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60)
    }
    
    class func readableDaysHoursMinutes(components: (d: Int, h: Int, m: Int)) -> String {
        var days    = ""
        var hours   = ""
        var minutes = "0 min"
        if components.d > 0 { days    = "\(components.d) d " }
        if components.h > 0 { hours   = "\(components.h) h " }
        if components.m > 0 { minutes = "\(components.m) min" }
        return days+hours+minutes
    }
    
    class func dateStringForTokenRequests(date: Date) -> String
    {
        let dateFormat = "dd MMM yyyy  HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

}
