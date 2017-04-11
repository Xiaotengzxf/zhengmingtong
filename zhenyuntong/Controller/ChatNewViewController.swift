//
//  ChatNewViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2017/3/30.
//  Copyright © 2017年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class ChatNewViewController: UIViewController , IQDropDownTextFieldDelegate {

    @IBOutlet weak var idtfTitle: IQDropDownTextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tvContent: PlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idtfTitle.dropDownMode = .textPicker
        idtfTitle.itemList = ["计划生育" , "户籍管理"]
        idtfTitle.optionalItemText = "选择工作流类型"
        if let mine = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
            tfName.text = mine["REALNAME"] as? String
        }
        if let mobile = UserDefaults.standard.object(forKey: "mobile") as? String {
            tfMobile.text = mobile
        }
        idtfTitle.rightView = rightView(name: "icon_menu_right", size: CGSize(width: 20, height: 20))
        idtfTitle.rightViewMode = .always
        tvContent.layer.cornerRadius = 5.0
        tvContent.layer.borderWidth = 0.5
        tvContent.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rightView(name : String, size : CGSize) -> UIView {
        let view = UIView()
        view.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        let iv = UIImageView(image: UIImage(named: name))
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: size.width))
        view.addConstraint(NSLayoutConstraint(item: iv, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: size.height))
        
        return view
    }
    
    @IBAction func save(_ sender: Any) {
        idtfTitle.resignFirstResponder()
        tfName.resignFirstResponder()
        tfMobile.resignFirstResponder()
        tvContent.resignFirstResponder()
        let name = tfName.text
        guard let title = idtfTitle.selectedItem else {
            Toast(text: "请选择工作流类型").show()
            return
        }
        guard let mobile = tfMobile.text , Invalidate.isPhoneNumber(phoneNumber: mobile) else {
            Toast(text: "电话输入有误").show()
            return
        }
        guard let content = tvContent.text else {
            Toast(text: "请输入咨询内容").show()
            return
        }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        let areaName = UserDefaults.standard.object(forKey: "areaName") as! String
        let mine = UserDefaults.standard.object(forKey: "mine") as! [String : Any]
        let hud = showHUD(text: "保存中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.saveQuestion, params: ["userId" : userId , "areaId" : areaId , "typeName" : title , "mobile" : mobile , "areaName" : areaName , "name" : name! , "header" : mine["HEADER"] as! String , "typeId" : idtfTitle.selectedRow , "isArea" : 0 , "userName" : name! , "content" : content]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    Toast(text: "发起留言成功").show()
                    _ = self?.navigationController?.popViewController(animated: true)
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                Toast(text : "网络故障，请检查网络").show()
            }
        }
        
    }
    
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?) {
       
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
