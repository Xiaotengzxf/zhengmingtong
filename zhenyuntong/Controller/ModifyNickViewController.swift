//
//  ModifyNickViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/9.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class ModifyNickViewController: UIViewController {
    @IBOutlet weak var nickTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = UserDefaults.standard.object(forKey: "mine") {
            let json = JSON(info)
            nickTextField.text = json["NICKNAME"].string
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveNick(_ sender: Any) {
        nickTextField.resignFirstResponder()
        if let nick = nickTextField.text , nick.characters.count > 0 {
            let nickname = nick.trimmingCharacters(in: .whitespacesAndNewlines)
            if nickname.characters.count > 0 {
                let userId = UserDefaults.standard.integer(forKey: "userId")
                let hud = self.showHUD(text: "加载中...")
                NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.modifyNickName, params: ["userId" : userId , "nickName" : nickname]){
                    [weak self] (json , error) in
                    hud.hide(animated: true)
                    if let object = json {
                        if let result = object["result"].int , result == 1000 {
                            if let info = UserDefaults.standard.object(forKey: "mine") {
                                var json = JSON(info)
                                json["NICKNAME"].string = nickname
                                UserDefaults.standard.set(json.object, forKey: "mine")
                                UserDefaults.standard.synchronize()
                            }
                            _ = self?.navigationController?.popViewController(animated: true)
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        
                    }
                }
            }else{
                Toast(text: "昵称输入有误").show()
            }
        }else{
            Toast(text: "请输入昵称").show()
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
