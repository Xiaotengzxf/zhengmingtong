//
//  DateManager.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/20.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import Foundation

class DateManager {
    
    static let installShared = DateManager()
    
    func dateFromDefaultToLocal(date : Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year , .month , .day , .hour , .minute , .second], from: date)
        return "\(components.month ?? 0)月\(components.day ?? 0)日 \(components.hour! > 12 ? "下午" : "上午") \(components.hour ?? 0):\(components.minute ?? 0)"
    }
    
    func dateFromDefaultToLocalString(dateString : String) -> String? {
        if dateString.characters.count >= 18 {
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = format.date(from: dateString) {
                return dateFromDefaultToLocal(date: date)
            }
        }
        return nil
    }
    
    func getCurrentDateString() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmssSSS"
        return format.string(from: date)
    }
    
    func getCurrentTimeString() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: date)
    }
    
}
