//
//  UpLoadFileView.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/16.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class UpLoadFileView: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!

    @IBAction func selectPhoto(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: 2, userInfo: ["tag" : tag])
    }
}
