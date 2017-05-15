//
//  RegisterViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import KeychainAccess

class RegisterViewController: UIViewController {

    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var repwdTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var btnTip: UIButton!
    //var timer : Timer?
    //var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func requestCode(_ sender: Any) {
//        self.view.endEditing(true)
//        let mobile = mobileTextField.text
//        if mobile == nil || mobile?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
//            Toast(text: "请输入手机号").show()
//            return
//        }else if !Invalidate.isPhoneNumber(phoneNumber: mobile!){
//            Toast(text: "手机号输入有误！").show()
//            return
//        }
//        if count == 60 {
//            if timer == nil {
//                codeButton.isEnabled = false
//                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RegisterViewController.startTimer(sender:)), userInfo: nil, repeats: true)
//                timer?.fire()
//            }
//            
//        }
//        Toast(text: "获取验证码成功").show()
//    }

    @IBAction func doRegister(_ sender: Any) {
        self.view.endEditing(true)
        //let name = nameTextField.text
        let pwd = pwdTextField.text
        let repwd = repwdTextField.text
        let mobile = mobileTextField.text
        let nick = nickTextField.text
        if mobile == nil || mobile?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入手机号").show()
            return
        }else if !Invalidate.isPhoneNumber(phoneNumber: mobile!){
            Toast(text: "手机号输入有误！").show()
            return
        }else if pwd == nil || pwd?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入密码").show()
            return
        }else if repwd != pwd {
            Toast(text: "二次密码输入不一致").show()
            return
        }else if nick == nil || nick?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入昵称").show()
            return
        }
        var imei = ""
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        if let uuid = keychain["uuid"] {
            imei = uuid
        }else{
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                keychain["uuid"] = uuid
                imei = uuid
            }
        }
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let hud = showHUD(text: "提交中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.regist, params: ["userId" : userId , "nickName" : nick! , "password" : DESHelper.encryptUseDES(pwd!) , "channel" : 1 , "mobile" : mobile! , "registType" : 1 , "userType" : 1 , "imei" : imei , "imsi" : imei]){ // imei imsi "account" : name!
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "注册成功").show()
                    
                    UserDefaults.standard.set(object["data"].dictionaryObject, forKey: "mine")
                    UserDefaults.standard.set(mobile!, forKey: "mobile")
                    UserDefaults.standard.set(object["data" , "USERID"].int, forKey: "userId")
                    UserDefaults.standard.set(pwd!, forKey: "pwd")
                    UserDefaults.standard.synchronize()
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }
    
    /*{
     data =     {
     ACCOUNT = 15815815811;
     "CATEGORY_ID" = 120;
     CHANNEL = 1;
     "CREATE_TIME" = "2017-05-15 18:09:34";
     CURRENTSTATE = 4;
     ID = "fd69ff0d-8fe9-4c60-8867-9cf01438b94a";
     IMEI = "D19F4BE8-03F5-4EEF-840F-EE927B848A94";
     IMSI = "D19F4BE8-03F5-4EEF-840F-EE927B848A94";
     "IS_DELETED" = "\U5426";
     MOBILE = 15815815811;
     NICKNAME = jack;
     "ORDER_ID" = 0;
     "ORGAN_ID" = 10001;
     PASSWORD = bd5102d39658cf2b;
     "REF_CATEGORY_ID" = 120;
     REGISTTIME = "2017-05-15 18:09:34";
     REGISTTYPE = 1;
     STATE = 1;
     USERID = 100040;
     USERTYPE = 1;
     };
     msg = "\U6ce8\U518c\U6210\U529f\Uff01";
     result = 1000;
     }*/
    
    
//    func startTimer(sender : Timer) {
//        count -= 1
//        if count <= 0 {
//            count = 60
//            codeButton.setTitle("获取验证码", for: .normal)
//            codeButton.isEnabled = true
//            timer?.invalidate()
//            timer = nil
//        }else{
//            codeButton.setTitle("\(count)秒可重发", for: .normal)
//        }
//        
//    }
    
    @IBAction func agreeTip(_ sender: Any) {
        btnTip.isSelected = !btnTip.isSelected
        registerButton.isEnabled = btnTip.isSelected
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
