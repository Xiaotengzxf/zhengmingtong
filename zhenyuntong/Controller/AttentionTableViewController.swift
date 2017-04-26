//
//  AttentionTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/11.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import MJRefresh
import DZNEmptyDataSet

class AttentionTableViewController: UITableViewController , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate {
    
    var attention : [JSON] = []
    var row = 0
    var bChooseArea = false // 是否从其他入口进入选择
    var bEmpty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadData()
        })
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 自定义方法
    
    func loadData() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.myFocusEreas, params: ["userId" : userId]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.attention.removeAll()
                    self?.attention += object["data"].arrayValue
                    self?.tableView.reloadData()
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

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attention.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let json = attention[indexPath.row]
        if let imageView = cell.contentView.viewWithTag(4) as? UIImageView {
            if let icon = json["areaIcon".uppercased()].string {
                let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
                imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
            }else if let icon = json["areaIcon"].string {
                let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
                imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
            }else{
                imageView.image = UIImage(named: "img_default_big")
            }
        }
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = json["areaName"].string
        }
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = json["focusTime"].string
        }
        if let imageView = cell.contentView.viewWithTag(5) as? UIImageView {
            imageView.isHidden = true
            if bChooseArea {
                if let areaName = UserDefaults.standard.object(forKey: "areaName") as? String {
                    if let areaName2 = json["areaName"].string {
                        if areaName == areaName2 {
                            imageView.isHidden = false
                        }
                    }
                }
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if bChooseArea {
            let json = attention[indexPath.row]
            UserDefaults.standard.set(json["areaId"].intValue, forKey: "areaId")
            UserDefaults.standard.set(json["areaName"].stringValue, forKey: "areaName")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(NotificationName.Commnunity.rawValue), object: 1)
            NotificationCenter.default.post(name: Notification.Name(NotificationName.InfoLook.rawValue), object: 1)
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            row = indexPath.row
            self.performSegue(withIdentifier: "areadetail", sender: self)
        }
    }
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "load_fail")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let att = NSMutableAttributedString(string: "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！")
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        /* CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
         
         animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
         animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
         
         animation.duration = 0.25;
         animation.cumulative = YES;
         animation.repeatCount = MAXFLOAT;*/
        return nil
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AreaListTableViewController {
            controller.other = attention.map({$0["areaId"].intValue})
        }else if let controller = segue.destination as? AreaDetailViewController {
            controller.item = attention[row]
            controller.bAttension = true
        }
        
    }
    

}
