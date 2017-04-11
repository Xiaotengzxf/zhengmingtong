//
//  CommonTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/19.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDCycleScrollView
import MJRefresh
import Toaster
import SKPhotoBrowser

class CommonTableViewController: UITableViewController , SDCycleScrollViewDelegate {
    
    var cycleScrollView : SDCycleScrollView?
    var item : JSON?
    var page = 0
    var tableData : [JSON] = []
    var ads : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if item == nil {
            tableView.tableHeaderView = nil
        }else{
            let rect = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENWIDTH * 504 / 900)
            tableView.tableHeaderView?.frame = rect
            cycleScrollView = SDCycleScrollView(frame: rect, delegate: self, placeholderImage: nil)
            cycleScrollView?.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
            cycleScrollView?.backgroundColor = UIColor.white
            cycleScrollView?.delegate = self
            tableView.tableHeaderView?.addSubview(cycleScrollView!)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.page = 0
            self?.loadData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            [weak self] in
            self?.page += 1
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * 加载数据
     */
    func loadData()  {
        if item == nil {
            let userId = UserDefaults.standard.integer(forKey: "userId")
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.myFavourite, params: ["userId" : userId , "pageIndex" : page]){
                [weak self] (json , error) in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                if var object = json {
                    if let result = object["result"].int , result == 1000 {
                        if self?.page == 0 {
                            self?.tableData.removeAll()
                        }
                        if let news = object["data"].array {
                            self?.tableData += news
                            if news.count < 20 {
                                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                        }
                        self?.tableView.reloadData()
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    
                }
            }
        }else{
            let areaId = UserDefaults.standard.integer(forKey: "areaId")
            let itemId = self.item!["newsItemId"].intValue
            let isArea = self.item!["isArea"].intValue
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.getNewsByItem, params: ["itemId" : itemId , "isArea" : isArea , "areaId" : areaId , "pageIndex" : page]){
                [weak self] (json , error) in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                if var object = json {
                    if let result = object["result"].int , result == 1000 {
                        if self?.ads.count == 0 {
                            if let topNews = object["data" , "topNews"].array {
                                if topNews.count > 0 {
                                    self?.ads += topNews
                                    self?.cycleScrollView?.imageURLStringsGroup = topNews.map({$0["imgUrl"].stringValue})
                                    self?.cycleScrollView?.titlesGroup = topNews.map({$0["reamrk"].stringValue})
                                    self?.cycleScrollView?.placeholderImage = UIImage(named: "img_default")
                                }else{
                                    self?.tableView.tableHeaderView = nil
                                }
                            }
                        }
                        if self?.page == 0 {
                            self?.tableData.removeAll()
                        }
                        if let news = object["data" , "news"].array {
                            self?.tableData += news
                            if news.count < 20 {
                                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                        }
                        self?.tableView.reloadData()
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 , message.characters.count > 0{
                            Toast(text: message).show()
                        }
                    }
                }else{
                    
                }
                
            }
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newItem = tableData[indexPath.row]
        let newsImgs = newItem["newsImgs"].array
        let count = newsImgs?.count ?? 0
        if count >= 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CommonOtherTableViewCell
            cell.imageWidthLC.constant = (SCREENWIDTH - 52) / 3
            cell.imageView1.sd_setImage(with: URL(string: newsImgs![0]["imageUrl"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
            cell.imageView2.sd_setImage(with: URL(string: newsImgs![1]["imageUrl"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
            cell.imageView3.sd_setImage(with: URL(string: newsImgs![2]["imageUrl"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
            if let title = newItem["newsTitle"].string {
                cell.nameLabel.text = title
            }else{
                cell.nameLabel.text = ""
            }
            cell.contentView.layoutIfNeeded()
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommonTableViewCell
            if count >= 1 {
                cell.iconWidthLC.constant = (SCREENWIDTH - 52) / 3
                cell.labelLeftLC.constant = (SCREENWIDTH - 52) / 3 + 26
                cell.iconImageView.sd_setImage(with: URL(string: newsImgs![0]["imageUrl"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
            }else{
                cell.iconWidthLC.constant = 0
                cell.labelLeftLC.constant = 16
                cell.iconImageView.image = nil
            }
            if let title = newItem["newsTitle"].string {
                cell.nameLabel.text = title
            }else{
                cell.nameLabel.text = ""
            }
            if let summary = newItem["newsSummary"].string {
                cell.contentLabel.text = summary
            }else{
                cell.contentLabel.text = ""
            }
            cell.timeLabel.text = DateManager.installShared.dateFromDefaultToLocalString(dateString: newItem["publishTime"].stringValue)
            cell.commentLabel.text = "评论：\(newItem["replyCount"].intValue)"
            cell.contentView.layoutIfNeeded()
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newItem = tableData[indexPath.row]
        let newsImgs = newItem["newsImgs"].array
        let count = newsImgs?.count ?? 0
        if count >= 3 {
            var images = [SKPhoto]()
            for newImg in newsImgs! {
                let photo = SKPhoto.photoWithImageURL(newImg["imageUrl"].stringValue)
                photo.shouldCachePhotoURLImage = false
                photo.caption = newImg["descrption"].stringValue
                images.append(photo)
            }
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            SKPhotoBrowserOptions.displayAction = false
            present(browser, animated: true, completion: { 
                
            })
        }else{
            if let linkUrl = newItem["linkUrl"].string {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "comment") as? CommentTableViewController {
                    controller.linkUrl = linkUrl
                    controller.adId = newItem[ "newsId"].intValue
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    // MARK: - 滚动条回调
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "comment") as? CommentTableViewController {
            controller.linkUrl = ads[index]["linkUrl"].string
            controller.adId = ads[index][ "newsId"].intValue
            self.navigationController?.pushViewController(controller, animated: true)
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
