//
//  Invalidate.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import Foundation

class Invalidate {
    
    class func isPhoneNumber(phoneNumber:String) -> Bool {
        if phoneNumber.characters.count == 0 {
            return false
        }
        let mobile = "^(13[0-9]|15[0-9]|18[0-9]|17[0-9]|147)\\d{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return true
        }else{
            return false
        }
    }
    
    static func randomMD5(identifierString : String) -> String {
        
        let cStr = identifierString.cString(using: .utf8)
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5(cStr, CC_LONG(strlen(cStr)), &digest)
        
        var output = String()
        
        for i in digest {
            
            output = output.appendingFormat("%02X", i)
        }
        
        return output;
    }
    
    // 验证邮箱
    static func isValidateEmail(email : String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    static func validate(regex : String , value : String) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailTest.evaluate(with: value)
    }
}
