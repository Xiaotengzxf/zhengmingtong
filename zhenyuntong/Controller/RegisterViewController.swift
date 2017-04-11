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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var repwdTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var codeButton: UIButton!
    var timer : Timer?
    var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestCode(_ sender: Any) {
        self.view.endEditing(true)
        let mobile = mobileTextField.text
        if mobile == nil || mobile?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入手机号").show()
            return
        }else if !Invalidate.isPhoneNumber(phoneNumber: mobile!){
            Toast(text: "手机号输入有误！").show()
            return
        }
        if count == 60 {
            if timer == nil {
                codeButton.isEnabled = false
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RegisterViewController.startTimer(sender:)), userInfo: nil, repeats: true)
                timer?.fire()
            }
            
        }
        Toast(text: "获取验证码成功").show()
    }

    @IBAction func doRegister(_ sender: Any) {
        self.view.endEditing(true)
        let name = nameTextField.text
        let pwd = pwdTextField.text
        let repwd = repwdTextField.text
        let mobile = mobileTextField.text
        let nick = nickTextField.text
        if name == nil || name?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入用户名").show()
            return
        }else if pwd == nil || pwd?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入密码").show()
            return
        }else if repwd != pwd {
            Toast(text: "二次密码输入不一致").show()
            return
        }else if mobile == nil || mobile?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入手机号").show()
            return
        }else if !Invalidate.isPhoneNumber(phoneNumber: mobile!){
            Toast(text: "手机号输入有误！").show()
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
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.regist, params: ["userId" : userId , "nickName" : nick! , "account" : name! , "password" : DESHelper.encryptUseDES(pwd!) , "channel" : 1 , "mobile" : mobile! , "registType" : 1 , "userType" : 1 , "imei" : imei , "imsi" : imei]){ // imei imsi
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "注册成功").show()
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
    
    func startTimer(sender : Timer) {
        count -= 1
        if count <= 0 {
            count = 60
            codeButton.setTitle("获取验证码", for: .normal)
            codeButton.isEnabled = true
            timer?.invalidate()
            timer = nil
        }else{
            codeButton.setTitle("\(count)秒可重发", for: .normal)
        }
        
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
