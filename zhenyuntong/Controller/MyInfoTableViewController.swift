//
//  MyInfoTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/9.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import ALCameraViewController
import SDWebImage
import SwiftyJSON
import Alamofire
import Toaster

class MyInfoTableViewController: UITableViewController {
    
    var image : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let info = UserDefaults.standard.object(forKey: "mine") {
            let json = JSON(info)
            if indexPath.section == 0 && indexPath.row == 0 {
                if let imageView = cell.viewWithTag(1) as? UIImageView {
                    if image != nil {
                        imageView.image = image
                    }else{
                        imageView.sd_setImage(with: URL(string: NetworkManager.installshared.macAddress() + json["HEADER"].stringValue) , placeholderImage: UIImage(named: "header_default"))
                    }
                }
            }else if indexPath.section == 0 && indexPath.row == 1 {
                cell.detailTextLabel?.text = json["MOBILE"].string
            }else if indexPath.section == 0 && indexPath.row == 2 {
                cell.detailTextLabel?.text = json["NICKNAME"].string
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                changeHeadImage()
            }else if indexPath.row == 1 {
                
            }else{
                self.performSegue(withIdentifier: "modifynick", sender: self)
            }
        }else {
            self.performSegue(withIdentifier: "modifypwd", sender: self)
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
    
    func changeHeadImage()  {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self?.dismiss(animated: true, completion: nil)
            if image != nil {
                self?.image = image
                self?.modifyHeader()
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    func modifyHeader() {
        let hud = showHUD(text: "加载中...")
        let userId = UserDefaults.standard.integer(forKey: "userId")
        Alamofire.upload(multipartFormData: {[weak self] (data) in
            data.append(UIImagePNGRepresentation(self!.image!)!, withName: "File", fileName: "\(Date().timeIntervalSince1970)crop.png", mimeType: "image/png")
            data.append("\(userId)".data(using: .utf8)!, withName: "userId")
        }, to: NetworkManager.installshared.macAddress() + "/bbServer/" + NetworkManager.installshared.modifyHeader) {[weak self] (result) in
            hud.hide(animated: true)
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {[weak self] response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let result = json["result"].int , result == 1000 {
                            self?.tableView.reloadData()
                            NotificationCenter.default.post(name: Notification.Name(NotificationName.Mine.rawValue), object: self!.image!)
                            if var mine = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
                                mine["HEADER"] = json["data" , "header"].stringValue
                                UserDefaults.standard.set(mine, forKey: "mine")
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
                print(encodingError)
            }
        }
    }

}
