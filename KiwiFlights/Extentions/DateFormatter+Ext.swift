//
//  DateFormatter+Ext.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 02/08/2023.
//

import Foundation


extension DateFormatter {
    static var serverFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
    
    static var shortFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }
    
    static var shortFormatNormal: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MM. @ H:mm"
        return formatter
    }
}

extension String {
    var shortTime: String {
        guard let date = DateFormatter.serverFormat.date(from: self)
        else { return "" }
        return DateFormatter.shortFormat.string(from: date)
    }
    
    var shortTimeNormal: String {
        guard let date = DateFormatter.serverFormat.date(from: self)
        else { return "" }
        return DateFormatter.shortFormatNormal.string(from: date)
    }
}
