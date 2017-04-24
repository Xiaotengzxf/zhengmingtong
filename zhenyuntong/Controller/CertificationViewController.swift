//
//  CertificationViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/10.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import ALCameraViewController
import Alamofire
import Photos
import SwiftyJSON

class CertificationViewController: UIViewController {

    @IBOutlet weak var cerTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var fView: UIView!
    @IBOutlet weak var tView: UIView!
    @IBOutlet weak var sView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    var tapOne : UITapGestureRecognizer?
    var tapTwo : UITapGestureRecognizer?
    var tapThree : UITapGestureRecognizer?
    var images : [Int : UIImage] = [:]
    var assets : [Int : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapOne = UITapGestureRecognizer(target: self, action: #selector(CertificationViewController.selectPhoto(sender:)))
        tapTwo = UITapGestureRecognizer(target: self, action: #selector(CertificationViewController.selectPhoto(sender:)))
        tapThree = UITapGestureRecognizer(target: self, action: #selector(CertificationViewController.selectPhoto(sender:)))
        tapOne?.numberOfTapsRequired = 1
        tapTwo?.numberOfTapsRequired = 1
        tapThree?.numberOfTapsRequired = 1
        fView.addGestureRecognizer(tapOne!)
        tView.addGestureRecognizer(tapTwo!)
        sView.addGestureRecognizer(tapThree!)
        fView.tag = 100
        tView.tag = 101
        sView.tag = 102
        if let certification = UserDefaults.standard.object(forKey: "certification") as? [String : Any] {
            if let name = certification["name"] as? String {
                nameTextField.text = name
            }
            if let cer = certification["cer"] as? String {
                cerTextField.text = cer
            }
            if let city = certification["city"] as? String {
                cityTextField.text = city
            }
            if let images = certification["images"] as? [Int : String] {
                if let imageView = self.fView.viewWithTag(2) as? UIImageView {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [images[0]!], options: nil)
                    PHImageManager().requestImage(for: assets[0], targetSize: CGSize.zero, contentMode: .aspectFit, options: nil, resultHandler: { (image, data) in
                        imageView.image = image
                    })
                }
                if let imageView = self.fView.viewWithTag(3) as? UIImageView {
                    imageView.isHidden = true
                }
                if let label = self.fView.viewWithTag(4) as? UILabel {
                    label.isHidden = true
                }
                if let imageView = self.tView.viewWithTag(2) as? UIImageView {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [images[1]!], options: nil)
                    PHImageManager().requestImage(for: assets[0], targetSize: CGSize.zero, contentMode: .aspectFit, options: nil, resultHandler: { (image, data) in
                        imageView.image = image
                    })
                }
                if let imageView = self.tView.viewWithTag(3) as? UIImageView {
                    imageView.isHidden = true
                }
                if let label = self.tView.viewWithTag(4) as? UILabel {
                    label.isHidden = true
                }
                if let imageView = self.sView.viewWithTag(2) as? UIImageView {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [images[2]!], options: nil)
                    PHImageManager().requestImage(for: assets[0], targetSize: CGSize.zero, contentMode: .aspectFit, options: nil, resultHandler: { (image, data) in
                        imageView.image = image
                    })
                }
                if let imageView = self.sView.viewWithTag(3) as? UIImageView {
                    imageView.isHidden = true
                }
                if let label = self.sView.viewWithTag(4) as? UILabel {
                    label.isHidden = true
                }
            }
        }else if let certification = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
            if let name = certification["REALNAME"] as? String {
                nameTextField.text = name
            }
            if let cer = certification["IDCARD"] as? String {
                cerTextField.text = cer
            }
            if let city = certification["ADDRESS"] as? String {
                cityTextField.text = city
            }
        }
        if let json = UserDefaults.standard.object(forKey: "mine") {
            let object = JSON(json)
            if let state = object["STATE"].int , state == 2 {
                submitButton.isEnabled = false
                submitButton.backgroundColor = UIColor.gray
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectPhoto(sender : UIGestureRecognizer) {
        let cameraViewController = CameraViewController(croppingEnabled: false) { [weak self] image, asset in
            // Do something with your image here.
            // If cropping is enabled this image will be the cropped version
            self?.dismiss(animated: true, completion: nil)
            if image != nil {
                let tag = sender.view?.tag ?? 0
                if tag == 100 {
                    self?.images[0] = image!
                    self?.assets[0] = asset!.localIdentifier
                    if let imageView = self?.fView.viewWithTag(2) as? UIImageView {
                        imageView.image = image
                    }
                    if let imageView = self?.fView.viewWithTag(3) as? UIImageView {
                        imageView.isHidden = true
                    }
                    if let label = self?.fView.viewWithTag(4) as? UILabel {
                        label.isHidden = true
                    }
                }else if tag == 101 {
                    self?.images[1] = image!
                    self?.assets[1] = asset!.localIdentifier
                    if let imageView = self?.tView.viewWithTag(2) as? UIImageView {
                        imageView.image = image
                    }
                    if let imageView = self?.tView.viewWithTag(3) as? UIImageView {
                        imageView.isHidden = true
                    }
                    if let label = self?.tView.viewWithTag(4) as? UILabel {
                        label.isHidden = true
                    }
                }else{
                    self?.images[2] = image!
                    self?.assets[2] = asset!.localIdentifier
                    if let imageView = self?.sView.viewWithTag(2) as? UIImageView {
                        imageView.image = image
                    }
                    if let imageView = self?.sView.viewWithTag(3) as? UIImageView {
                        imageView.isHidden = true
                    }
                    if let label = self?.sView.viewWithTag(4) as? UILabel {
                        label.isHidden = true
                    }
                }
            }
        }
        self.present(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func doSubmit(_ sender: Any) {
        nameTextField.resignFirstResponder()
        cerTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let name = nameTextField.text
        let cer = cerTextField.text
        let city = cityTextField.text
        if name == nil || name?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "姓名不能为空").show()
            return
        }else if cer == nil || cer?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "身份证号不能为空").show()
            return
        }else if city == nil || city?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "家庭住址不能为空").show()
            return
        }
        guard let _ = images[0] else {
            Toast(text: "请上传身份证正面照片").show()
            return
        }
        guard let _ = images[1] else {
            Toast(text: "请上传身份证反面照片").show()
            return
        }
        guard let _ = images[2] else {
            Toast(text: "本人手持身份证").show()
            return
        }
        let hud = self.showHUD(text: "提交中...")
        Alamofire.upload(multipartFormData: {[weak self] (data) in
            data.append(name!.data(using: .utf8)!, withName: "realName")
            data.append(cer!.data(using: .utf8)!, withName: "idCard")
            data.append(city!.data(using: .utf8)!, withName: "address")
            data.append("\(UserDefaults.standard.integer(forKey: "userId"))".data(using: .utf8)!, withName: "userId")
            for (key , image) in self!.images {
                data.append(UIImageJPEGRepresentation(image, 1)!, withName: "file\(key + 1)", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpg")
            }
        }, to: NetworkManager.installshared.macAddress() + "/bbServer/" + NetworkManager.installshared.authentication) {[weak self] (result) in
            hud.hide(animated: true)
            print(result)
            switch result {
            case .success(_, _, _):
                if var json = UserDefaults.standard.object(forKey: "mine") as? [String : Any] {
                    json["STATE"] = 3
                    UserDefaults.standard.set(json, forKey: "mine")
                    UserDefaults.standard.set(["name" : name! , "cer" : cer! , "city" : city! , "assets" : self!.assets], forKey: "certification")
                    UserDefaults.standard.synchronize()
                }
                _ = self?.navigationController?.popViewController(animated: true)
            case .failure(let encodingError):
                print(encodingError)
            }
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
