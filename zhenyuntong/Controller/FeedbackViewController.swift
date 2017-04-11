//
//  FeedbackViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/11.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var textView: PlaceholderTextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func submitFeedBack(_ sender: Any) {
        textView.resignFirstResponder()
        textField.resignFirstResponder()
        let content = textView.text
        let email = textField.text
        if content == nil || content?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入您的宝贵意见").show()
            return
        }else if (email != nil && email!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 && !Invalidate.isValidateEmail(email: email!)) {
            Toast(text: "email输入有误").show()
            return
        }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        var params : [String : Any] = ["userId" : userId , "content" : content!.trimmingCharacters(in: .whitespacesAndNewlines)]
        if email != nil {
            params["link"] = email!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let hud = self.showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.feedback, params: params){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    _ = self?.navigationController?.popViewController(animated: true)
                    Toast(text: "意见反馈成功").show()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                
            }
        }
    }
    
        
}
