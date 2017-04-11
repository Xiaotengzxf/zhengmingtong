//
//  InputView.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/15.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift

class InputView: UIView , IQDropDownTextFieldDelegate , IQDropDownTextFieldDataSource {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: IQDropDownTextField!
    var item : JSON?
    
    func addRadioButton(keyValues : [JSON] , value : Int) {
        var buttons : [RadioButton] = []
        let x = 96
        var tem = 0
        for i in 0..<keyValues.count {
            let keyValue = keyValues[i]
            let radioButton = RadioButton(frame: CGRect(x: x + i * 80, y: 0, width: 80, height: 44))
            radioButton.addTarget(self, action: #selector(InputView.onRadioButtonValueChanged(sender:)), for: .touchUpInside)
            radioButton.setTitle(keyValue["value"].stringValue, for: .normal)
            radioButton.setTitleColor(UIColor.darkGray, for: .normal)
            radioButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            radioButton.setImage(UIImage(named: "unchecked"), for: .normal)
            radioButton.setImage(UIImage(named: "checked"), for: .selected)
            radioButton.contentHorizontalAlignment = .center
            radioButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0)
            radioButton.contentHorizontalAlignment = .left
            self.addSubview(radioButton)
            buttons.append(radioButton)
            let key = keyValue["key"].intValue
            radioButton.tag = key
            if key == value {
                tem = i
            }
        }
        buttons[0].groupButtons = buttons
        buttons[tem].isSelected = true

    }
    
    func onRadioButtonValueChanged(sender : RadioButton) {
        NotificationCenter.default.post(name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: 1, userInfo: ["tag" : tag , "value" : sender.tag])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.textField.dropDownMode == .textField {
            if let text = textField.text , text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
                let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
                NotificationCenter.default.post(name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: 1, userInfo: ["tag" : tag , "value" : value])
            }
        }
    }
    
    func textField(_ textField: IQDropDownTextField, didSelect date: Date?) {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let dateString = format.string(from: date!)
        NotificationCenter.default.post(name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: 1, userInfo: ["tag" : tag , "value" : dateString])
    }
    
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
        if let keyValues = self.item?["keyValues"].array {
            for keyValue in keyValues {
                if keyValue["value"].string == item {
                    NotificationCenter.default.post(name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: 1, userInfo: ["tag" : tag , "value" : keyValue["key"].intValue])
                    break
                }
            }
        }
    }

}
