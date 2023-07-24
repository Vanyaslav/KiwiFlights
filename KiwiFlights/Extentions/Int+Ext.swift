//
//  Int+Ext.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 24/07/2023.
//

import Foundation

extension Int {
    var hoursFormatFromSeconds: String {
        let minutes = (self % 3600) / 60
        let hours = (self / 3600)
            
        switch minutes {
        case 0...9:
            return "\(hours) hours : 0\(minutes) min."

        default:
            return "\(hours) hours : \(minutes) min."
        }
    }
    
    var hoursFormatFromSecondsShort: String {
        let minutes = (self % 3600) / 60
        let hours = (self / 3600)
            
        switch minutes {
        case 0...9:
            return "\(hours) h : 0\(minutes) m"

        default:
            return "\(hours) h : \(minutes) m"
        }
    }
}
