//
//  NewsTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/19.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import Toaster

class NewsTableViewController: UITableViewController {
    
    var data : JSON?
    var news : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.loadData()
        })
        tableView.mj_header.beginRefreshing()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData() {
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.getQuestionDet, params: ["id" : data!["id"].stringValue]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    let array = object["data"].arrayValue
                    self?.news = array
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

    @IBAction func reply(_ sender: Any) {
        let alert = UIAlertController(title: "咨询回复", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: {[weak self] (action) in
            if let textfield = alert.textFields?.first {
                if let text = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) , text.characters.count > 0 {
                    let userId = UserDefaults.standard.integer(forKey: "userId")
                    let areaId = UserDefaults.standard.integer(forKey: "areaId")
                    let mine = UserDefaults.standard.object(forKey: "mine") as! [String : Any]
                    NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.reply, params: ["header" : mine["HEADER"] as! String , "isArea" : 0 , "userName" : mine["REALNAME"] as! String , "areaId" : areaId , "userId" : userId , "content" : text , "id" : self!.data!["id"].stringValue]){
                        [weak self] (json , error) in
                        self?.tableView.mj_header.endRefreshing()
                        if let object = json {
                            if let result = object["result"].int , result == 1000 {
                                self?.tableView.mj_header.beginRefreshing()
                                Toast(text: "回复成功").show()
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
                    Toast(text: "请输入回复内容").show()
                }
            }
        }))
        alert.addTextField { (textfiled) in
            textfiled.placeholder = "回复内容"
        }
        self.present(alert, animated: true) { 
            
        }
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = news[indexPath.row]
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = item["content"].string
        }
        
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = item["replyTime"].string
        }
        
        
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            var url = item["userHeader"].stringValue
            if !url.hasPrefix("http://") {
                url = NetworkManager.installshared.macAddress() + url
            }
            imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
        }
        if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
            let image = UIImage(named: "bg_diggle_white")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 20, 20, 20))
            imageView.image = image
        }
        if let imageView = cell.contentView.viewWithTag(11) as? UIImageView {
            if indexPath.row == 0 {
                imageView.isHidden = true
            }else{
                imageView.isHidden = false
            }
        }
        if let imageView = cell.contentView.viewWithTag(10) as? UIImageView {
            if indexPath.row == news.count - 1 {
                imageView.isHidden = true
            }else{
                imageView.isHidden = false
            }
        }
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = news[indexPath.row]
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "webview") as? WebViewController {
            controller.linkUrl = item["linkUrl"].string
            controller.title = item["title"].string
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
