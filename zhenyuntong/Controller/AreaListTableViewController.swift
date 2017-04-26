//
//  AreaListTableViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/11.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

class AreaListTableViewController: UITableViewController {
    
    var areas : [JSON] = []
    var data : [String : JSON] = [:]
    var capital : [String : [String]] = [:]
    var indexes : [String] = []
    var other : [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(AreaListTableViewController.handleNotification(sender:)), name: Notification.Name(NotificationName.AreaList.rawValue), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 自定义方法
    
    func loadData() {
        NetworkManager.installshared.request(type: .get, url: NetworkManager.installshared.ereaList, params: nil){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.areas.removeAll()
                    if var str = object["data"].string {
                        str = str.replacingOccurrences(of: "\\\"", with: "\"")
                        let arr = JSON(data: str.data(using: .utf8)!)
                        self?.areas += arr.arrayValue
                        let keys = arr.arrayValue.map{$0["AREANAME".uppercased()].stringValue}
                        var k : Set<String> = []
                        var ks : [String : [String]] = [:]
                        for key in keys {
                            let c = NSString(format: "%c", pinyinFirstLetter(NSString(string : key).character(at: 0))).uppercased
                            k.insert(c)
                            if let _ = ks[c] {
                                ks[c]! += [key]
                            }else{
                                ks[c] = [key]
                            }
                        }
                        let arrk = Array(k)
                        self!.indexes = arrk.sorted(by: <)
                        for index in self!.indexes {
                            let array = ks[index]!.sorted(by: { (s1, s2) -> Bool in
                             let str1 = NSString(string : s1)
                             let mStr1 = NSMutableString()
                             for i in 0..<str1.length  {
                             mStr1.appendFormat("%c", pinyinFirstLetter(str1.character(at: i)))
                             }
                             let str2 = NSString(string : s2)
                             let mStr2 = NSMutableString()
                             for i in 0..<str2.length  {
                             mStr2.appendFormat("%c", pinyinFirstLetter(str2.character(at: i)))
                             }
                             return String(mStr1).compare(String(mStr2)) == .orderedAscending
                             })
                            self!.capital[index] = array
                        }
                        
                        for json in arr.arrayValue {
                            self?.data[json["AREANAME".uppercased()].stringValue] = json
                        }
                    }
                    self?.tableView.reloadData()
                }else{
                    if let message = object["msg"].string , message.characters.count > 0 {
                        Toast(text: message).show()
                    }
                }
            }else{
                print(error?.localizedDescription ?? "")
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }
    
    // 处理通知
    func handleNotification(sender : Notification)  {
        if let tag = sender.object as? Int {
            if let item = sender.userInfo?["item"] as? JSON {
                if tag == 1 {
                    other.append(item["AREAID".uppercased()].int ?? 0)
                }else if tag == 2 {
                    let areaId = item["AREAID".uppercased()].int ?? 0
                    var tem = 0
                    for(index , aId) in other.enumerated() {
                        if areaId == aId {
                            tem = index
                        }
                    }
                    other.remove(at: tem)
                }
            }
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capital[indexes[section]]?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let array = capital[indexes[indexPath.section]] {
            let json = data[array[indexPath.row]]
            if let imageView = cell.contentView.viewWithTag(4) as? UIImageView {
                if let icon = json?["areaIcon".uppercased()].string {
                    let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
                    imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
                }else if let icon = json?["areaIcon"].string {
                    let url = icon.hasPrefix("http") ? icon : "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=\(icon)"
                    imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "img_default_big"))
                }else{
                    imageView.image = UIImage(named: "img_default_big")
                }
            }
            if let label = cell.contentView.viewWithTag(2) as? UILabel {
                label.text = json?["AREANAME".uppercased()].string
            }
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = json?["areaAddress".uppercased()].string
            }
            if let imageView = cell.contentView.viewWithTag(5) as? UIImageView {
                imageView.isHidden = !other.contains(json?["areaId".uppercased()].int ?? 0)
            }
            if let label = cell.contentView.viewWithTag(6) as? UILabel {
                label.isHidden = !other.contains(json?["areaId".uppercased()].int ?? 0)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return indexes.index(of: title) ?? 0
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexes
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "areadetail") as? AreaDetailViewController {
            if let array = capital[indexes[indexPath.section]] {
                let json = data[array[indexPath.row]]
                controller.item = json
                controller.bAttension = other.contains(json?["areaId".uppercased()].int ?? 0)
                NotificationCenter.default.post(name: Notification.Name(NotificationName.InfoLook.rawValue), object: 1)
                self.navigationController?.pushViewController(controller, animated: true)
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
