//
//  AreaDetailViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/12.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class AreaDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var areaNameLabel: UILabel!
    @IBOutlet weak var attentionImageView: UIImageView!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    var item : JSON?
    var bAttension = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let icon = item?["areaIcon".uppercased()].string {
            let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
            imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
        }else if let icon = item?["areaIcon"].string {
            let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
            imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
        }else{
            imageView.image = UIImage(named: "img_default_big")
        }
        
        if let areaName = item?["areaName".uppercased()].string {
            areaNameLabel.text = areaName
        }else if let areaName = item?["areaName"].string {
            areaNameLabel.text = areaName
        }
        if let address = item?["areaAddress".uppercased()].string {
            addressLabel.text = address
        }else if let address = item?["areaAddress"].string {
            addressLabel.text = address
        }
        attentionImageView.isHidden = !bAttension
        attentionLabel.text = bAttension ? "已关注" : "未关注"
        cancelButton.setTitle(bAttension ? "取消" : "关注", for: .normal)
        
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
    @IBAction func doCancel(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let areaId = item?["areaId".uppercased()].int ?? 0
        if bAttension {
            let hud = showHUD(text: "正在取消关注")
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.cancelErea, params: ["userId" : userId , "areaId" : areaId]){
                [weak self] (json , error) in
                hud.hide(animated: true)
                if let object = json {
                    if let result = object["result"].int , result == 1000 {
                        Toast(text: "取消关注成功").show()
                        NotificationCenter.default.post(name: Notification.Name(NotificationName.AreaList.rawValue), object: 2, userInfo: ["item" : self!.item!])
                        _ = self?.navigationController?.popViewController(animated: true)
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络出错，请检查网络").show()
                }
            }
        }else{
            let hud = showHUD(text: "正在添加关注")
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.focusErea, params: ["userId" : userId , "areaId" : areaId]){
                [weak self] (json , error) in
                hud.hide(animated: true)
                if let object = json {
                    if let result = object["result"].int , result == 1000 {
                        Toast(text: "添加关注成功").show()
                        NotificationCenter.default.post(name: Notification.Name(NotificationName.AreaList.rawValue), object: 1, userInfo: ["item" : self!.item!])
                        _ = self?.navigationController?.popViewController(animated: true)
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
        
    }
    
    @IBAction func doSend(_ sender: Any) {
        if bAttension {
            if let chatnew = self.storyboard?.instantiateViewController(withIdentifier: "chatnew") as? ChatNewViewController {
                self.navigationController?.pushViewController(chatnew, animated: true)
            }
        }else{
            Toast(text: "请先关注社区").show()
        }
    }
    
    

}
