//
//  InfoLookTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SDCycleScrollView
import SwiftyJSON
import Toaster
import MJRefresh
import DZNEmptyDataSet

class InfoLookTableViewController: UITableViewController , SDCycleScrollViewDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate , InfoLookTableViewCellDelegate {

    var cycleScrollView : SDCycleScrollView?
    var infoLookJson : JSON?
    var button : UIButton?
    var adsIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rect = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENWIDTH * 265 / 400)
        tableView.tableHeaderView?.frame = rect
        cycleScrollView = SDCycleScrollView(frame: rect, delegate: self, placeholderImage: nil)
        cycleScrollView?.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        cycleScrollView?.backgroundColor = UIColor.white
        cycleScrollView?.delegate = self
        tableView.tableHeaderView?.addSubview(cycleScrollView!)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
        if let infoLook = UserDefaults.standard.object(forKey: "infoLook") as? [String : Any] {
            infoLookJson = JSON(infoLook)
            refreshData()
        }
        setNavigationRightItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(InfoLookTableViewController.handleNotification(sender:)), name: Notification.Name(NotificationName.InfoLook.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if infoLookJson != nil {
            UserDefaults.standard.set(infoLookJson!.dictionaryObject!, forKey: "infoLook")
            UserDefaults.standard.synchronize()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.InfoLook.rawValue), object: nil)
    }
    
    /**
    * 加载数据
    */
    func loadData()  {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.getNewsItem, params: nil){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if var object = json {
                if let result = object["result"].int , result == 1000 {
                    if self!.infoLookJson != nil {
                        let items = self!.infoLookJson!["data" , "items"].arrayValue
                        var nItems = object["data" , "items"].arrayValue
                        for (index , item) in items.enumerated() {
                            let m = min(items.count, nItems.count)
                            if index >= m {
                                break
                            }
                            var nItem = nItems[index]
                            for childItem in item["childItems"].arrayValue {
                                if let actionType = childItem["actionType"].int , actionType >= 10 {
                                    for (index , nChildItem) in nItem["childItems"].arrayValue.enumerated() {
                                        if childItem["newsItemId"].intValue == nChildItem["newsItemId"].intValue {
                                            nItem["childItems" , index] = childItem
                                        }
                                    }
                                }
                            }
                            nItems[index] = nItem
                        }
                        object["data" , "items"].arrayObject = nItems
                    }
                    self?.infoLookJson = object
                    self?.refreshData()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                
            }
            
        }
    }
    
    func refreshData() {
        cycleScrollView?.imageURLStringsGroup = infoLookJson?["data" , "ads"].arrayValue.map({$0["adImgUrl"].stringValue.hasPrefix("http") ? $0["adImgUrl"].stringValue : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\($0["adImgUrl"].stringValue)"})
        cycleScrollView?.titlesGroup = infoLookJson?["data" , "ads"].arrayValue.map({$0["remark"].stringValue})
        cycleScrollView?.placeholderImage = UIImage(named: "img_default")
        tableView.reloadData()
    }
    
    func setNavigationRightItem()  {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        let arrowImageView = UIImageView(frame: CGRect(x: 100, y: 13.5, width: 20, height: 17))
        arrowImageView.image = UIImage(named: "bar_down")
        arrowImageView.contentMode = .scaleAspectFit
        rightView.addSubview(arrowImageView)
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 98, height: 44))
        button?.contentHorizontalAlignment = .right
        if let areaName = UserDefaults.standard.object(forKey: "areaName") as? String {
            button?.setTitle(areaName, for: .normal)
        }else{
            button?.setTitle("未关注", for: .normal)
        }
        button?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button?.addTarget(self, action: #selector(InfoLookTableViewController.changeArea), for: .touchUpInside)
        rightView.addSubview(button!)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
    }
    
    func changeArea() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if  userId > 0 {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "attention") as? AttentionTableViewController {
                controller.bChooseArea = true
                controller.title = "选择社区"
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else{
            if let controller = storyboard?.instantiateViewController(withIdentifier: "login") {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
    }
    
    func handleNotification(sender : Notification) {
        let tag = sender.object as? Int ?? 0
        if tag == 1 {
            if let areaName = UserDefaults.standard.object(forKey: "areaName") as? String {
                button?.setTitle(areaName, for: .normal)
            }
            
        }else if tag == 2 {
            if let tag = sender.userInfo?["tag"] as? Int {
                if let items = sender.userInfo?["items"] as? [JSON] {
                    infoLookJson?["data" , "items" , tag , "childItems"].arrayObject = items
                    tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - InfoLookTableViewCellDelegate
    
    func tableViewDidSelectedIndexPathWith(tag: Int, info: [String : Any]) {
        if tag == 2 {
            let item = info["item"]! as! JSON
            if var actionType = item["actionType"].int {
                if actionType >= 10 {
                    actionType -= 10
                }
                if actionType == 1 {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "common") as? CommonTableViewController {
                        controller.item = item
                        controller.title = item["newsItemName"].string
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    }
                }else if actionType == 2 {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "webview") as? WebViewController {
                        controller.linkUrl = item["linkUrl"].string
                        controller.title = item["newsItemName"].string
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }else {
                    
                }
            }
            
        }else if tag == 3 {
            if let userinfo = info as? [String : Int] {
                let tag = userinfo["tag"]
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "vertical") as? VerticalViewController {
                    controller.items = infoLookJson!["data" , "items" , tag! , "childItems"].arrayValue
                    controller.tag = tag!
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoLookJson?["data" , "items"].array?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoLookTableViewCell

        cell.titleLabel.text = infoLookJson?["data" , "items" , indexPath.row , "newsItemName"].string
        let items = infoLookJson?["data" , "items" , indexPath.row , "childItems"].array
        let filterItems = items?.filter({$0["actionType"].intValue < 10})
        cell.items = filterItems
        cell.tag = indexPath.row
        let bMore = (items?.count ?? 0) != (filterItems?.count ?? 0)
        cell.bMore = bMore
        cell.delegate = self
        let row = ((bMore ? 1 : 0) + (filterItems?.count ?? 0) > 4) ? 2 : 1
        let rowHeight = (SCREENWIDTH - 3) / 4 * 8 / 10
        cell.layoutConstraint.constant = CGFloat(row) * rowHeight + CGFloat(row + 2)
        cell.collectionView.reloadData()
        if let layout = cell.collectionView.collectionViewLayout as? CollectionViewHorizontalLayout {
            layout.rowCount = row
        }else{
            let layout = CollectionViewHorizontalLayout()
            layout.rowCount = row
            layout.scrollDirection = .horizontal
            cell.collectionView.collectionViewLayout = layout
        }
        if var count = filterItems?.count {
            if count < 8 {
                cell.pageControl.isHidden = true
            }else{
                cell.pageControl.isHidden = (items!.count > 8) ? false : true
            }
            count += (bMore ? 1 : 0)
            cell.pageControl.numberOfPages = count % 8 > 0 ? count / 8 + 1 : count / 8
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return (SCREENWIDTH - 3) / 4 * 8 / 10 + 2
    }
    
    // MARK: - 滚动条回调
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        adsIndex = index
        self.performSegue(withIdentifier: "comment", sender: self)
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CommentTableViewController {
            controller.linkUrl = self.infoLookJson?["data" , "ads" , adsIndex , "linkUrl"].string
            controller.adId = self.infoLookJson!["data" , "ads" , adsIndex , "objId"].intValue
            controller.imageUrl = self.infoLookJson?["data" , "ads" , adsIndex , "adImgUrl"].string
        }
    }
    
}
