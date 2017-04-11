//
//  ServerSettingViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster

class ServerSettingViewController: UIViewController {
    @IBOutlet weak var ipTextfield: UITextField!
    @IBOutlet weak var portTextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: -自定义方法
    @IBAction func saveIpAndPort(_ sender: Any) {
        ipTextfield.resignFirstResponder()
        portTextfield.resignFirstResponder()
        let ip = ipTextfield.text
        let port = portTextfield.text
        if ip == nil || ip!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "ip地址不能为空").show()
            return
        }else if !Invalidate.validate(regex: "(\\d{3}.){4}", value: ip!) {
            Toast(text: "ip地址输入有误").show()
            return
        }else if port == nil || port!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "端口不能为空").show()
            return
        }else if Int(port!) ?? 0 > 65025 {
            Toast(text: "端口输入有误").show()
            return
        }
        UserDefaults.standard.set("http://\(ip!):\(port!)", forKey: "mac")
        UserDefaults.standard.synchronize()
        Toast(text: "保存成功").show()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
