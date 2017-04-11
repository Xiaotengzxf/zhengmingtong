//
//  Extansion.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/12.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    func showHUD(text : String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = text
        return hud
    }
}

extension CALayer {
    func setBorderColorFromUIColor(_ color:UIColor ){
        self.borderColor = color.cgColor
    }
}
