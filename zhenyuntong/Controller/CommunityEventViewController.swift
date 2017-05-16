//
//  CommunityEventViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/15.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Toaster
import ALCameraViewController
import IQKeyboardManagerSwift
import Photos

class CommunityEventViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var contentView : IQPreviousNextView?
    var item : JSON?
    var regexes : [String : String] = [:]
    var height : CGFloat = 0
    var state = 0
    var index = 0 
    var images : [String : [String : UIImage]] = [:]
    var localImages : [String : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView = IQPreviousNextView()
        contentView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView!)
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView" : contentView!]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView" : contentView!]))
        if let name = item?["WORKTYPENAME"].string {
            self.title = name
        }else if let name = item?["workTypeName"].string {
            self.title = name
        }else{
            self.title = item?["workName"].string
        }
        let attaches = item?["PARAMS" , "attach"].array ?? item?["params" , "attach"].array
        let attachCount = attaches?.count ?? 0
        let params = item?["PARAMS" , "params"].array ?? item?["params" , "params"].array
        let paramsCount = params?.count ?? 0
        if paramsCount > 0 {
            for (index , json) in params!.enumerated() {
                if let inputType = json["inputType"].string {
                    addInputView(json: json, type: inputType , last: index == paramsCount - 1 && attachCount == 0 && state == 3 , tag : index)
                    height += 44
                }
            }
        }
        if let attachs = attaches , attachs.count > 0 {
            for (index , attach) in attachs.enumerated() {
                if let uploadFileView = Bundle.main.loadNibNamed("UpLoadFileView", owner: nil, options: nil)?.first as? UpLoadFileView {
                    uploadFileView.tag = index + 100
                    uploadFileView.translatesAutoresizingMaskIntoConstraints = false
                    contentView?.addSubview(uploadFileView)
                    contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[uploadFileView(width)]|", options: .directionLeadingToTrailing, metrics: ["width" : SCREENWIDTH], views: ["uploadFileView" : uploadFileView]))
                    contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[uploadFileView(height)]\(state == 3 && index == attachs.count - 1 ? "-10-|" : "")", options: .directionLeadingToTrailing, metrics: ["top" : height , "height" : SCREENWIDTH - 128], views: ["uploadFileView" : uploadFileView]))
                    height += SCREENWIDTH - 128
                    uploadFileView.label.text = attach["text"].string
                    uploadFileView.button.imageView?.contentMode = .scaleAspectFit
                    if localImages.count > 0 {
                        if let local = localImages["\(index)"] {
                            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [local], options: nil)
                            if assets.count > 0 {
                                PHImageManager.default().requestImageData(for: assets[0], options: nil, resultHandler: {[weak self] (data, _, _, _) in
                                    if data != nil {
                                        uploadFileView.button.setImage(UIImage(data: data!), for: .normal)
                                        self?.images["\(index)"] = [local : UIImage(data: data!)!]
                                    }
                                })
                            }
                        }
                    }else{
                        let url = NetworkManager.installshared.macAddress() + attach["value"].stringValue
                        if url.hasSuffix(".png") || url.hasSuffix(".jpg") || url.hasSuffix(".jpeg"){
                            if let url1 = URL(string : url) {
                                uploadFileView.button.sd_setImage(with: url1, for: .normal, placeholderImage: UIImage(named: "img_default_big"))
                            }
                        }
                    }
                }
            }
        }
        addSubmitButton() // 提交按钮
        NotificationCenter.default.addObserver(self, selector: #selector(CommunityEventViewController.handleNotification(sender:)), name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: nil)
        
        if state == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "草稿箱", style: .plain, target: self, action: #selector(CommunityEventViewController.dropInDraft))
        }else if state == 4 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(CommunityEventViewController.dropInDraft))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.CommunityEvent.rawValue), object: nil)
    }
    
    // 添加进草稿箱
    func dropInDraft() {
        if state == 4  {
            let alert = UIAlertController(title: "提示", message: "您确定要删除吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {(action) in
                
            }))
            alert.addAction(UIAlertAction(title: "删除", style: .default, handler: {[weak self]  (action) in
                NotificationCenter.default.post(name: Notification.Name("eventVC"), object: 1, userInfo: ["index" : self!.index])
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: { 
                
            })
        }else {
            self.view.endEditing(true)
            var dic : [String : String] = [:]
            if images.count > 0 {
                for (index , values) in images {
                    for (key , _) in values {
                        dic["\(index)"] = key
                    }
                }
            }
            if var local = UserDefaults.standard.object(forKey: "local") as? [Any] {
                item?["workName"].string = self.title!
                item?["submitTime"].string = DateManager.installShared.getCurrentTimeString()
                local.append(["item" : item!.dictionaryObject! , "images" : dic , "regex" : regexes])
                UserDefaults.standard.set(local, forKey: "local")
                UserDefaults.standard.synchronize()
            }else{
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                item?["CREATE_TIME"].string = format.string(from: Date())
                let local = [["item" : item!.dictionaryObject! , "images" : dic , "regex" : regexes]]
                UserDefaults.standard.set(local, forKey: "local")
                UserDefaults.standard.synchronize()
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleNotification(sender : Notification)  {
        if let tag = sender.object as? Int , tag == 1 {
            if let userInfo = sender.userInfo as? [String : Any] {
                let row = userInfo["tag"] as! Int
                if let value = userInfo["value"] as? Int {
                    item?["PARAMS", "params" , row , "value"].int = value
                    item?["params", "params" , row , "value"].int = value
                }else if let value = userInfo["value"] as? String {
                    item?["PARAMS" , "params" , row , "value"].string = value
                    item?["params" , "params" , row , "value"].string = value
                }
            }
        }else if let tag = sender.object as? Int , tag == 2 {
            if let userInfo = sender.userInfo as? [String : Any] {
                let row = userInfo["tag"] as! Int
                uploadImage(tag: row)
            }
            
            
        }
    }
    
    func addInputView(json : JSON , type : String , last : Bool , tag : Int) {
        if let inputView = Bundle.main.loadNibNamed("InputView", owner: nil, options: nil)?.first as? InputView {
            inputView.tag = tag
            inputView.item = json
            inputView.translatesAutoresizingMaskIntoConstraints = false
            contentView?.addSubview(inputView)
            
            contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputView(width)]|", options: .directionLeadingToTrailing, metrics: ["width" : SCREENWIDTH], views: ["inputView" : inputView]))
            contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[inputView(44)]\(last ? "-10-|" : "")", options: .directionLeadingToTrailing, metrics: ["top" : height], views: ["inputView" : inputView]))
            inputView.label.text = json["text"].string
            if type == "number" {
                inputView.textField.keyboardType = .numberPad
                inputView.textField.dropDownMode = .textField
                let textField = inputView.textField as UITextField
                textField.text = json["value"].string
            }else if type == "date" {
                inputView.textField.dropDownMode = .datePicker
                let textField = inputView.textField as UITextField
                textField.text = json["value"].string
            }else if type == "checkbox" {
                inputView.textField.isHidden = true
                if let keyValues = json["keyValues"].array {
                    inputView.addRadioButton(keyValues: keyValues , value : json["value"].intValue)
                }
            }else if type == "selector" {
                inputView.textField.dropDownMode = .textPicker
                if let keyValues = json["keyValues"].array {
                    inputView.textField.isOptionalDropDown = false
                    inputView.textField.itemList = keyValues.map({$0["value"].stringValue})
                    for (index , keyValue) in keyValues.enumerated() {
                        if keyValue["key"].intValue == json["value"].intValue {
                            inputView.textField.selectedRow = index
                            break
                        }
                    }
                }
            }else{
                inputView.textField.dropDownMode = .textField
                let textField = inputView.textField as UITextField
                textField.text = json["value"].string
                if json["name"].string == "idCard" {
                    textField.keyboardType = .alphabet
                }
            }
        }
    }
    
    func addSubmitButton() {
        if state == 0 || state == 4 {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("提交", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor.orange
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(CommunityEventViewController.doSubmit(sender:)), for: .touchUpInside)
            contentView?.addSubview(button)
            
            contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[button]-(16)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["button" : button]))
            contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[button(44)]-(10)-|", options: .directionLeadingToTrailing, metrics: ["top" : height], views: ["button" : button]))
        }else if state == 2 || state == 1{
            for i in 0..<2 {
                let button = UIButton(type: .custom)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle(i == 0 ? "撤销" : "修改", for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.backgroundColor = UIColor.orange
                button.layer.cornerRadius = 5
                button.clipsToBounds = true
                button.addTarget(self, action: #selector(CommunityEventViewController.doSubmit(sender:)), for: .touchUpInside)
                button.tag = 10000 + i
                contentView?.addSubview(button)
                
                contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[button(width)]\(i == 0 ? "" : "-16-|")", options: .directionLeadingToTrailing, metrics: ["left" : i == 0 ? 16 : (SCREENWIDTH - 42) / 2 + 26 , "width" : (SCREENWIDTH - 42) / 2], views: ["button" : button]))
                contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[button(44)]-(10)-|", options: .directionLeadingToTrailing, metrics: ["top" : height], views: ["button" : button]))
            }
        }
    }
    
    func doSubmit(sender : AnyObject)  {
        self.view.endEditing(true)
        let tag = (sender as! UIButton).tag
        if tag == 10000 {
            let alert = UIAlertController(title: "系统提示", message: "是否要撤销申请", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: {[weak self] (action) in
                
                /*workName	计划生育
                 sendHeader	/bbServer/upload/1482677327416.jpg
                 senderId	100032
                 workId	58
                 sendName	张大
                 toUser	2
                 areaUser	0*/
                let hud = self?.showHUD(text: "正在撤销中...")
                NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.cancelWork, params: ["workName" : self!.title! , "sendHeader" : "/bbServer/upload/1482677327416.jpg" , "senderId" : UserDefaults.standard.integer(forKey: "userId") , "workId" : self!.item!["workId"].intValue , "sendName" : self!.item!["nickName"].stringValue , "toUser" : 2 , "areaUser" : 0]){
                    [weak self] (json , error) in
                    hud?.hide(animated: true)
                    if let object = json {
                        if let result = object["result"].int , result == 1000 {
                            _ = self?.navigationController?.popViewController(animated: true)
                            Toast(text: "撤销成功").show()
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        
                    }
                }
                
            }))
            present(alert, animated: true, completion: { 
                
            })
        }else{
            let attaches = item?["PARAMS" , "attach"].array ?? item?["params" , "attach"].array
            //let attachCount = attaches?.count ?? 0
            let params = item?["PARAMS" , "params"].array ?? item?["params" , "params"].array
            let paramsCount = params?.count ?? 0
            if paramsCount > 0 {
                for (_ , json) in params!.enumerated() {
                    if let require = json["require"].int , require == 1 {
                        if let inputType = json["inputType"].string {
                            if inputType == "selector" || inputType == "checkbox" || inputType == "radio" {
                                
                            }else{
                                let value = json["value"].stringValue
                                if value.characters.count == 0 {
                                    Toast(text: "\(json["text"].stringValue)不能为空！").show()
                                    return
                                }
                                let regex = json["regex"].stringValue
                                if regex.characters.count > 0 {
                                    if !Invalidate.validate(regex: regexes[regex] ?? "", value: value) {
                                        Toast(text: "\(json["text"].stringValue)输入有误").show()
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if let attachs = attaches , attachs.count > 0 {
                for (index , attach) in attachs.enumerated() {
                    if let require = attach["require"].int , require == 1 {
                        if images["\(index)"] == nil && state == 0 {
                            Toast(text: "请上传\(attach["text"].stringValue)").show()
                            return
                        }
                    }
                }
            }
            let alert = UIAlertController(title: "提示", message: "确认提交吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: {[weak self] (action) in
                let hud = self?.showHUD(text: "提交中...")
                Alamofire.upload(multipartFormData: {[weak self] (data) in
                    let attaches = self?.item?["PARAMS" , "attach"].array ?? self?.item?["params" , "attach"].array
                    for (key , value) in self!.images {
                        for (name , image) in value {
                            data.append(UIImageJPEGRepresentation(image, 0.2)!, withName: attaches![Int(key)!]["name"].stringValue, fileName: "\(name).png", mimeType: "image/png")
                        }
                    }
                    data.append(self!.title!.data(using: .utf8)!, withName: "workName")
                    if self!.state == 2 || self!.state == 1 {
                        var workId = 0
                        workId = self!.item!["WORKID"].intValue
                        if workId == 0 {
                            workId = self!.item!["workId"].intValue
                        }
                        data.append("\(workId)".data(using: .utf8)!, withName: "workId")
                    }else{
                        var workTypeId = 0
                        workTypeId = self!.item!["WORKTYPEID"].intValue
                        if workTypeId == 0 {
                            workTypeId = self!.item!["workTypeId"].intValue
                        }
                        data.append("\(workTypeId)".data(using: .utf8)!, withName: "workTypeId")
                    }
                    if let json = UserDefaults.standard.object(forKey: "mine") {
                        let object = JSON(json)
                        var nickName = ""
                        nickName = object["NICKNAME"].stringValue
                        if nickName.characters.count == 0 {
                            nickName = object["nickName"].stringValue
                        }
                        data.append(nickName.data(using: .utf8)!, withName: "sendName")
                    }
                    data.append("0".data(using: .utf8)!, withName: "areaUser")
                    data.append("\(UserDefaults.standard.integer(forKey: "userId"))".data(using: .utf8)!, withName: self!.state == 2 || self!.state == 1 ? "senderId" : "userId")
                    data.append("\(UserDefaults.standard.integer(forKey: "areaId"))".data(using: .utf8)!, withName: self!.state == 2 || self!.state == 1 ? "toUser" : "areaId")
                    var str = self?.item?["PARAMS"].rawString() ?? ""
                    if str.characters.count == 0 || str == "null" {
                        str = self?.item?["params"].rawString() ?? ""
                    }
                    if str.characters.count > 0 && str != "null" {
                        
                        if let array = self?.regexes , array.count > 0 {
                            for (key , regex) in array {
                                str = str.replacingOccurrences(of: key, with: regex)
                            }
                        }
                        str = str.replacingOccurrences(of: "\\\"", with: "\"")
                        str = str.replacingOccurrences(of: "\n", with: "")
                        str = str.replacingOccurrences(of: "\r", with: "")
                        str = str.replacingOccurrences(of: " ", with: "")
                        str = str.replacingOccurrences(of: "\"}\"", with: "\"}")
                        str = str.replacingOccurrences(of: "]}\"", with: "]}")
                        str = str.replacingOccurrences(of: "\"{\"", with: "{\"")
                        str = str.replacingOccurrences(of: "\\\\", with: "\\")
                        data.append(str.data(using: .utf8)!, withName: "params")
                    }
                    data.append("/bbServer/upload/\(Date().timeIntervalSince1970).jpg".data(using: .utf8)!, withName: "sendHeader")
                }, to: NetworkManager.installshared.macAddress() + "/bbServer/" + (self!.state == 2 || self!.state == 1 ? NetworkManager.installshared.modify : NetworkManager.installshared.submit)) { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON {[weak self] response in
                            hud?.hide(animated: true)
                            if let value = response.result.value {
                                let json = JSON(value)
                                if let result = json["result"].int , result == 1000 {
                                    Toast(text: "提交成功").show()
                                    _ = self?.navigationController?.popViewController(animated: true)
                                    if var local = UserDefaults.standard.object(forKey: "local") as? [[String : Any]] {
                                        if self!.index < local.count {
                                            local.remove(at: self!.index)
                                        }
                                        UserDefaults.standard.set(local, forKey: "local")
                                        UserDefaults.standard.synchronize()
                                    }
                                }else{
                                    if let msg = json["msg"].string , msg.characters.count > 0 {
                                        Toast(text: msg).show()
                                    }
                                }
                            }
                        }
                    case .failure(let encodingError):
                        hud?.hide(animated: true)
                        print(encodingError)
                        Toast(text: "提交失败").show()
                    }
                }
                
                
            }))
            present(alert, animated: true, completion: {
                
            })
            
        }
    }

    func uploadImage(tag : Int)  {
        let cameraViewController = CameraViewController(croppingEnabled: false) { [weak self] image, asset in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self?.dismiss(animated: true, completion: nil)
            if image != nil {
                if let uploadFileView = self?.view.viewWithTag(tag) as? UpLoadFileView {
                    uploadFileView.button.setImage(image!, for: .normal)
                }
                self?.images["\(tag - 100)"] = [asset!.localIdentifier : image!]
                self?.localImages["\(tag - 100)"] = asset!.localIdentifier
                
            }
        }
        present(cameraViewController, animated: true, completion: nil)
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
