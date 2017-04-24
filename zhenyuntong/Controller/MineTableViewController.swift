//
//  MineTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/5.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class MineTableViewController: UITableViewController , MyInfoTableViewControllerDelegate {
    
    private var titles : [[String]] = []
    var image : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        titles = [["请点击登录" , "服务器设置" , "关于我们" , "意见反馈" , "清除缓存"] , ["是否接收通知" , "实名认证" , "我的关注" , "我的收藏"]]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if userId > 0 {
             tableView.tableFooterView?.isHidden = false
        }else{
             tableView.tableFooterView?.isHidden = true
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // 退出登录
    @IBAction func loginOut(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "确定退出吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
            UserDefaults.standard.removeObject(forKey: "mine")
            UserDefaults.standard.set(0, forKey: "userId")
            UserDefaults.standard.set(0, forKey: "areaId")
            UserDefaults.standard.removeObject(forKey: "areaName")
            self?.tableView.tableFooterView?.isHidden = true
            self?.tableView.reloadData()
        }))
        self.present(alert, animated: true) { 
            
        }
    }
    
    func calculateCacheSize() -> String {
        let size = SDImageCache.shared().getSize()
        if size < 1024 * 1024 {
            return "\(String(format: "%.2f", arguments: [Float(size) / 1024]))KB"
        }else if size < 1024 * 1024 * 1024 {
            return "\(String(format: "%.2f", arguments: [Float(size) / 1024 / 1024]))MB"
        }
        return "0.00B"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        }else{
            return 4
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 && indexPath.row == 0 ? "Cell1" : "Cell2", for: indexPath)

        // Configure the cell...
        if indexPath.section == 0 && indexPath.row == 0 {
            let userId = UserDefaults.standard.integer(forKey: "userId")
            if let constraint = cell.contentView.constraints.filter({$0.identifier == "constraint"}).first {
                if userId > 0 {
                    constraint.constant = -10
                }else{
                    constraint.constant = 0
                }
            }
            if userId > 0 {
                if let json = UserDefaults.standard.object(forKey: "mine") {
                    let object = JSON(json)
                    if let label = cell.viewWithTag(2) as? UILabel {
                        label.text = "昵称：" + object["NICKNAME"].stringValue
                    }
                    if let imageView = cell.viewWithTag(1) as? UIImageView {
                        if image != nil {
                            imageView.image = image
                        }else{
                            imageView.sd_setImage(with: URL(string: NetworkManager.installshared.macAddress() + object["HEADER"].stringValue) , placeholderImage: UIImage(named: "header_default"))
                        }
                    }
                    if let label = cell.viewWithTag(3) as? UILabel {
                        label.text = "帐号：" + object["ACCOUNT"].stringValue
                    }
                }
                
            }else{
                if let label = cell.viewWithTag(2) as? UILabel {
                    label.text = titles[indexPath.section][indexPath.row]
                }
                if let imageView = cell.viewWithTag(1) as? UIImageView {
                    imageView.image = UIImage(named: "header_default")
                }
                if let label = cell.viewWithTag(3) as? UILabel {
                    label.text = nil
                }
            }
            
        }else{
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = titles[indexPath.section][indexPath.row]
            }
            if let label = cell.viewWithTag(2) as? UILabel {
                if indexPath.section == 1 && indexPath.row == 1 {
                    if let json = UserDefaults.standard.object(forKey: "mine") {
                        let object = JSON(json)
                        if let state = object["STATE"].int {
                            if state == 2 {
                                label.text = "认证成功"
                            }else if state == 3 {
                                label.text = "认证中"
                            }else if state == 1{
                                label.text = "注册用户"
                            }else{
                                label.text = "注销"
                            }
                        }
                    }
                }else if indexPath.section == 0 && indexPath.row == 5 {
                    label.text = calculateCacheSize()
                }else{
                    label.text = nil
                }
            }
            if let imageView = cell.viewWithTag(3) as? UIImageView {
                imageView.isHidden = true
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else{
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let userId = UserDefaults.standard.integer(forKey: "userId")
                if userId > 0 {
                    self.performSegue(withIdentifier: "myinfo", sender: self)
                }else{
                    self.performSegue(withIdentifier: "login", sender: self)
                }
                
            }else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "serversetting", sender: self)
            }else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "aboutme", sender: self)
            }else if indexPath.row == 3 {
                let userId = UserDefaults.standard.integer(forKey: "userId")
                if userId > 0 {
                    self.performSegue(withIdentifier: "feedback", sender: self)
                }else{
                    self.performSegue(withIdentifier: "login", sender: self)
                }
            }else if indexPath.row == 4 {
                let alert = UIAlertController(title: "提示", message: "需要清空缓存吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    
                }))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
                    SDImageCache.shared().clearDisk()
                    self?.tableView.reloadData()
                }))
                self.present(alert, animated: true, completion: { 
                    
                })
            }
        }else{
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: "certification", sender: self)
            }else if indexPath.row == 0 {
                let userId = UserDefaults.standard.integer(forKey: "userId")
                if userId > 0 {
                    self.performSegue(withIdentifier: "notice", sender: self)
                }else{
                    self.performSegue(withIdentifier: "login", sender: self)
                }
            }else if indexPath.row == 2 {
                let userId = UserDefaults.standard.integer(forKey: "userId")
                if userId > 0 {
                    self.performSegue(withIdentifier: "attention", sender: self)
                }else{
                    self.performSegue(withIdentifier: "login", sender: self)
                }
            }else{
                let userId = UserDefaults.standard.integer(forKey: "userId")
                if userId > 0 {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "common") as? CommonTableViewController {
                        controller.title = "我的收藏"
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                }else{
                    self.performSegue(withIdentifier: "login", sender: self)
                }
                
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MyInfoTableViewController {
            controller.delegate = self
        }
    }
    
    func modifyHeader(data: Data?) {
        if data != nil {
            image = UIImage(data: data!)
            tableView.reloadData()
        }
    }
}
