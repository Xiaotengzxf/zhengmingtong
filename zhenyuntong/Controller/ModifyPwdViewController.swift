//
//  ModifyPwdViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/9.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class ModifyPwdViewController: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var oldTextField: UITextField!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var reNewTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNewPwd(_ sender: Any) {
        oldTextField.resignFirstResponder()
        newTextField.resignFirstResponder()
        reNewTextField.resignFirstResponder()
        let oldPwd = oldTextField.text
        let newPwd = newTextField.text
        let reNewPwd = reNewTextField.text
        if oldPwd == nil || oldPwd?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入旧密码").show()
            return
        }else if newPwd == nil || newPwd?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入新密码").show()
            return
        }else if reNewPwd != newPwd {
            Toast(text: "二次密码输入不一致").show()
            return
        }
        if let pwd = UserDefaults.standard.string(forKey: "pwd") {
            if pwd != oldPwd {
                Toast(text: "旧密码输入有误").show()
                return
            }
        }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let password = newPwd!.trimmingCharacters(in: .whitespacesAndNewlines)
        let hud = self.showHUD(text: "加载中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.modifyPassword, params: ["userId" : userId , "newPassword" : DESHelper.encryptUseDES(password)]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    UserDefaults.standard.set(password, forKey: "pwd")
                    UserDefaults.standard.synchronize()
                    _ = self?.navigationController?.popViewController(animated: true)
                    Toast(text: "密码修改成功").show()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                
            }
        }
    }
    
    // MARK: - textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let len = textField.text?.characters.count , len >= 20 {
            if range.length == 0 {
                return false
            }
        }
        return true
    }

}
