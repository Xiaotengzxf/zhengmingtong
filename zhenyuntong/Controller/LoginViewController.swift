//
//  LoginViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/6.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class LoginViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mobile = UserDefaults.standard.object(forKey: "mobile") as? String {
            userNameTextField.text = mobile
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doLogin(_ sender: Any) {
        resign()
        let mobile = userNameTextField.text
        let pwd = pwdTextField.text
        if mobile == nil || mobile?.characters.count == 0 {
            Toast(text: "请输入手机号").show()
            return
        }else if !Invalidate.isPhoneNumber(phoneNumber: mobile!) {
            Toast(text: "手机号输入有误!").show()
            return
        }else if pwd == nil || pwd?.characters.count == 0 {
            Toast(text: "请输入密码").show()
            return
        }
        let hud = self.showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.login, params: ["account" : mobile! , "password" : DESHelper.encryptUseDES(pwd!)]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    UserDefaults.standard.set(object["data"].dictionaryObject, forKey: "mine")
                    UserDefaults.standard.set(mobile!, forKey: "mobile")
                    UserDefaults.standard.set(object["data" , "USERID"].int, forKey: "userId")
                    UserDefaults.standard.set(pwd!, forKey: "pwd")
                    UserDefaults.standard.synchronize()
                    _ = self?.navigationController?.popViewController(animated: true)
                    
                    JPUSHService.setAlias(mobile!, callbackSelector: nil, object: nil)
                    
                    /*ACCOUNT = 15220277437;
                     ADDRESS = "\U6e56\U5317\U5b89\U5c45";
                     "CATEGORY_ID" = 120;
                     CHANNEL = 1;
                     "CREATE_TIME" = "2016-12-06 19:53:24";
                     HEADER = "/bbServer/upload/1481027019285.jpg";
                     ID = "a4547f54-3fcc-4d4d-bb8f-116619eddc87";
                     IDCARD = 420982198710133210;
                     IMEI = 359786058845604;
                     IMSI = 460022200657877;
                     "IS_DELETED" = "\U5426";
                     MOBILE = 15220277437;
                     NICKNAME = "\U5317\U65b9\U7684\U72fc123";
                     OPENID = "";
                     "ORDER_ID" = 0;
                     "ORGAN_ID" = 10001;
                     PASSWORD = 08B80D2C2A4F95CB8C18932A38B734E8;
                     REALNAME = "\U4e25\U8000\U8f89";
                     "REF_CATEGORY_ID" = 120;
                     REGISTTIME = "2016-12-06 19:53:24";
                     REGISTTYPE = 1;
                     STATE = 2;
                     USERID = 100000;
                     USERTYPE = 1;
                     加载是件正经事儿，走心加载中...
*/
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                
            }
        }
    }

    @IBAction func doRegister(_ sender: Any) {
        resign()
        
    }
    
    @IBAction func doForgetPwd(_ sender: Any) {
        resign()
    }
    
    // 取消输入焦点
    func resign()  {
        userNameTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTextField {
            if let len = textField.text?.characters.count , len >= 11 {
                if range.length == 0 {
                    return false
                }
            }
        }else{
            if let len = textField.text?.characters.count , len >= 20 {
                if range.length == 0 {
                    return false
                }
            }
        }
        return true
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
