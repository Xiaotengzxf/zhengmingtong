//
//  ChatTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import SDWebImage
import MJRefresh
import DZNEmptyDataSet

class ChatTableViewController: UITableViewController, DZNEmptyDataSetSource , DZNEmptyDataSetDelegate {
    
    var chatJson : [JSON] = []
    var selectedRow = 0
    var page = 0
    var nShowEmpty = 2 // 1 无网络 2 加载中 3  无数据  4 未登录 5 未选择小区

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.page = 0
            self?.loadData()
        })
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.page += 1
            self?.loadData()
        })
        tableView.mj_footer.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if  userId > 0 {
            let areaId = UserDefaults.standard.integer(forKey: "areaId")
            if areaId > 0 {
                nShowEmpty = 2
            }else{
                nShowEmpty = 5
                chatJson.removeAll()
                tableView.reloadData()
            }
        }else{
            nShowEmpty = 4
            chatJson.removeAll()
            tableView.reloadData()
        }
        if nShowEmpty == 2 {
            loadData()
        }else{
            if nShowEmpty != 4 && nShowEmpty != 5 {
                tableView.mj_header.beginRefreshing()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.getQuestions, params: ["userId" : userId , "areaId" : areaId , "page" : page]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let result = object["result"].int {
                    if result == 1000 {
                        if self!.page == 0 {
                            self?.tableView.mj_footer.isHidden = false
                            self?.chatJson.removeAll()
                        }
                        if let array = object["data"].array {
                            if self?.page == 0 {
                                if array.count > 0 {
                                    self?.nShowEmpty = 0
                                }else{
                                    self?.nShowEmpty = 3
                                }
                            }
                            if array.count < 20 {
                                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                            self?.chatJson += array
                        }
                        self?.tableView.reloadData()
                        var count = 0
                        for item in self!.chatJson {
                            count += item["unReadCount"].intValue
                        }
                        NotificationCenter.default.post(name: Notification.Name("TabBarController"), object: count)
                        
                    }else if result == 1004 {
                        if self!.page == 0 {
                            self?.nShowEmpty = 1
                            self?.tableView.reloadData()
                        }
                    }else{
                        if self?.page == 0 {
                            self?.nShowEmpty = 3
                            self?.tableView.reloadData()
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }
                }
            }else{
                if self?.page == 0 {
                    self?.nShowEmpty = 1
                    self?.tableView.reloadData()
                }else{
                    Toast(text : "网络故障，请检查网络").show()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatJson.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let label = cell.contentView.viewWithTag(2) as? UILabel {
            label.text = chatJson[indexPath.row]["question"].string
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = "咨询类型：\(chatJson[indexPath.row]["typeName"].string ?? "") 咨询时间：\(chatJson[indexPath.row]["createTime"].string ?? "")"
        }
        if let label = cell.contentView.viewWithTag(20) as? UILabel {
            label.isHidden = true
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            if let unReadCount = chatJson[indexPath.row]["unReadCount"].int, unReadCount > 0 {
                label.isHidden = false
                label.text = "\(unReadCount)"
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "news", sender: self)
        
        var count = 0
        for item in chatJson {
            count += item["unReadCount"].intValue
        }
        if count > 0 {
            count = count - chatJson[indexPath.row]["unReadCount"].intValue
        }
        if count >= 0 {
            NotificationCenter.default.post(name: Notification.Name("TabBarController"), object: count)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? NewsTableViewController {
            let item = chatJson[selectedRow]
            controller.data = item
        }
    }
    @IBAction func createChat(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if  userId > 0 {
            let areaId = UserDefaults.standard.integer(forKey: "areaId")
            if areaId > 0 {
                self.performSegue(withIdentifier: "chatnew", sender: self)
            }else{
                if let controller = storyboard?.instantiateViewController(withIdentifier: "attention") as? AttentionTableViewController {
                    controller.bChooseArea = true
                    controller.title = "选择社区"
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
        }else{
            if let controller = storyboard?.instantiateViewController(withIdentifier: "login") {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var name = ""
        if nShowEmpty == 1 {
            name = "load_fail"
        }else if nShowEmpty == 2 {
            name = "jiazaizhong"
        }else {
            name = "empty"
        }
        return UIImage(named: name)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "空空如也，啥子都没有噢！"
        }else if nShowEmpty == 4 {
            message = "请先登录"
        }else if nShowEmpty == 5 {
            message = "请先选择社区"
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty == 2
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty > 0 && nShowEmpty != 2 {
            if nShowEmpty == 4 {
                if let controller = storyboard?.instantiateViewController(withIdentifier: "login") {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else if nShowEmpty == 5 {
                if let controller = storyboard?.instantiateViewController(withIdentifier: "attention") as? AttentionTableViewController {
                    controller.bChooseArea = true
                    controller.title = "选择社区"
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else{
                nShowEmpty = 2
                tableView.reloadData()
                loadData()
            }
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
        animation.duration = 0.5
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }

}
