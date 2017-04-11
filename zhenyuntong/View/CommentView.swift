//
//  CommentView.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/17.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster

class CommentView: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentView.tapHideCommentView(sender:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    func tapHideCommentView(sender : UITapGestureRecognizer)  {
        textField.resignFirstResponder()
        bottomLayoutConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) {[weak self] (finished) in
            self?.isHidden = true
        }
    }
    
    @IBAction func doSubmit(_ sender: Any) {
        if let text = textField.text , text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            textField.resignFirstResponder()
            NotificationCenter.default.post(name: Notification.Name(NotificationName.Comment.rawValue), object: 1, userInfo: ["content" : text])
        }else{
            Toast(text: "请输入评论").show()
        }
        
    }
    
    func showWithKeyboard(height : CGFloat , duration : TimeInterval) {
        bottomLayoutConstraint.constant = height
        UIView.animate(withDuration: duration, animations: { 
            self.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    func hideWithKeyboard(duration : TimeInterval) {
        bottomLayoutConstraint.constant = 0
        UIView.animate(withDuration: duration, animations: { 
            self.layoutIfNeeded()
        }) {[weak self] (finished) in
            
        }
    }

}
