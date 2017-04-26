//
//  EventTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import MJRefresh

class EventViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tag = 0
    var page = 0
    var items : [JSON] = []
    var images : [[String : String]] = []
    var regexes : [[String : String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = false
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
       
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventViewController.handleNotification(notification:)), name: Notification.Name("eventVC"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tag == 4 {
            if let local = UserDefaults.standard.object(forKey: "local") as? [[String : Any]] {
                self.items.removeAll()
                self.images.removeAll()
                for subLocal in local {
                    if let item = subLocal["item"] {
                        items.append(JSON(item))
                        
                    }
                    if let item = subLocal["images"] as? [String : String] {
                        images.append(item)
                    }
                    if let regex = subLocal["regex"] as? [String : String] {
                        regexes.append(regex)
                    }
                }
            }
            tableView.reloadData()
        }else{
            tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
                [weak self] in
                self?.page = 0
                self?.loadData()
            })
            tableView.mj_footer =  MJRefreshAutoNormalFooter(refreshingBlock: {
                [weak self] in
                self?.page += 1
                self?.loadData()
            })
            tableView.mj_header.beginRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData()  {
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        let userId = UserDefaults.standard.integer(forKey: "userId")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.workList, params: ["workState" : tag , "areaId" : areaId , "pageIndex" : page , "userId" : userId]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if self!.page == 0 {
                        self?.items.removeAll()
                    }
                    if let array = object["data"].array {
                        self?.items += array
                        if array.count < 20 {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                    self?.tableView.reloadData()
                }else{
                    self?.addEmptyView()
                }
            }else{
                print(error?.localizedDescription ?? "")
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }
    
    func addEmptyView() {
        if let emptyView = Bundle.main.loadNibNamed("EmptyView", owner: nil, options: nil)?.first as? EmptyView {
            emptyView.label.text = "空空如也，啥子都没有噢！"
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emptyView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(EventViewController.tapEvent(sender:)))
            tap.numberOfTapsRequired = 1
            emptyView.addGestureRecognizer(tap)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["emptyView" : emptyView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptyView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["emptyView" : emptyView]))
        }
    }
    
    func tapEvent(sender : UITapGestureRecognizer) {
        if let view = sender.view {
            view.removeFromSuperview()
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    func handleNotification(notification : Notification) {
        if tag == 4 {
            if let tag = notification.object as? Int {
                if tag == 1 {
                    if let userInfo = notification.userInfo as? [String : Int] {
                        let index = userInfo["index"] ?? 0
                        items.remove(at: index)
                        tableView.reloadData()
                        if items.count == 0 {
                            UserDefaults.standard.removeObject(forKey: "local")
                        }else{
                            if var local = UserDefaults.standard.object(forKey: "local") as? [[String : Any]] {
                                local.remove(at: index)
                                UserDefaults.standard.set(local, forKey: "local")
                                UserDefaults.standard.synchronize()
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell
        let json = items[indexPath.row]
        cell.nameLabel.text = json["workName"].string ?? json["WORKTYPENAME"].stringValue
        if var submitTime = json["submitTime"].string {
            if submitTime.characters.count > 10 {
                submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
            }
            cell.dateLabel.text = submitTime
        }else if var submitTime = json["CREATE_TIME"].string {
            if submitTime.characters.count > 10 {
                submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
            }
            cell.dateLabel.text = submitTime
        }
        if tag < 4 {
            let state = json["state"].intValue
            if state == 2 {
                cell.stateLabel.text = "处理中"
                cell.timeLabel.text = ""
            }else if state == 3 {
                cell.stateLabel.text = "已完成"
                if var submitTime = json["completeTime"].string {
                    if submitTime.characters.count > 10 {
                        submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
                    }
                    cell.timeLabel.text = "完成时间：\(submitTime)"
                }
                
            }else if state == 1 {
                cell.stateLabel.text = "待处理"
                if var submitTime = json["completeTime"].string {
                    if submitTime.characters.count > 10 {
                        submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
                    }
                    cell.timeLabel.text = "反馈时间：\(submitTime)"
                }
            }else{
                cell.stateLabel.text = "已终止"
                if var submitTime = json["completeTime"].string {
                    if submitTime.characters.count > 10 {
                        submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
                    }
                    cell.timeLabel.text = "终止时间：\(submitTime)"
                }
            }
        }
        if tag == 1 || tag == 3 {
            if let reason = json["failReason"].string {
                cell.resultLabel.text = reason
            }else {
                cell.resultLabel.text = nil
            }
        }else{
            cell.resultLabel.text = nil
        }
         // 2 处理中 3 已完成 4 已终止
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tag == 1 || tag == 3 {
            return 90
        }else{
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var userInfo : [String : Any] = [:]
        if tag < 4 {
            userInfo = ["item" : items[indexPath.row].object , "state" : tag]
        }else{
            userInfo = ["item" : items[indexPath.row].object , "state" : tag]
            if images.count > indexPath.row {
                userInfo["images"] = images[indexPath.row]
            }
            if regexes.count > indexPath.row {
                userInfo["regex"] = regexes[indexPath.row]
            }
            userInfo["index"] = indexPath.row
        }
        NotificationCenter.default.post(name: Notification.Name(NotificationName.Commnunity.rawValue), object: 2, userInfo: userInfo)
    }
}
