//
//  SearchTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/21.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class SearchTableViewController: UITableViewController , IQDropDownTextFieldDelegate {

    @IBOutlet weak var dateTextField: IQDropDownTextField! // 办理时间
    @IBOutlet weak var reasonTextField: UITextField! // 事项名称
    @IBOutlet weak var searchButton: UIButton! // 搜索按钮
    var tableData : [JSON] = []
    var dateString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTextField.dropDownMode = .datePicker
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
        let json = tableData[indexPath.row]
        cell.nameLabel.text = json["workName"].string
        if var submitTime = json["submitTime"].string {
            if submitTime.characters.count > 10 {
                submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
            }
            cell.dateLabel.text = submitTime
        }
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
            
        }else {
            cell.stateLabel.text = "已终止"
            if var submitTime = json["completeTime"].string {
                if submitTime.characters.count > 10 {
                    submitTime = submitTime.substring(to: submitTime.index(submitTime.startIndex, offsetBy: 10))
                }
                cell.timeLabel.text = "终止时间：\(submitTime)"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item = tableData[indexPath.row]
        let params = item["params"].stringValue
        let (param , dic) = regex(data: params)
        let json = JSON.parse(param)
        item["params"] = json
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "communityevent") as? CommunityEventViewController {
            controller.item = item
            controller.regexes = dic!
            controller.state = item["state"].intValue
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func regex(data : String) -> (String , [String : String]?) {
        var newData = data
        let reg = "\"regex\":\"[^\"]+\""
        do {
            var dictionary : [String : String] = [:]
            let ex = try NSRegularExpression(pattern: reg, options: .caseInsensitive)
            //let value = ex.stringByReplacingMatches(in: data, options: .reportCompletion, range: NSMakeRange(0, NSString(string: data).length), withTemplate: "\"regex\":\"\"")
            let result = ex.matches(in: data, options: .reportCompletion, range: NSMakeRange(0, NSString(string: data).length))
            for i in 0..<result.count {
                let res = result[result.count - i - 1]
                let range = res.range
                dictionary["aaaaaa\(i)"] = newData.substring(with: newData.index(newData.startIndex, offsetBy: range.location)..<newData.index(newData.startIndex, offsetBy: range.location + range.length))
                newData = newData.replacingCharacters(in: newData.index(newData.startIndex, offsetBy: range.location)..<newData.index(newData.startIndex, offsetBy: range.location + range.length), with: "\"regex\":\"aaaaaa\(i)\"")
                
            }
            return (newData , dictionary)
        }catch{
            
        }
        return ("" , nil)
    }
    
    // MARK: - 自定义方法
    
    /// 搜索事项
    ///
    /// - Parameter sender: 按钮
    @IBAction func searchSomething(_ sender: Any) {
        dateTextField.resignFirstResponder()
        reasonTextField.resignFirstResponder()
        let reason = reasonTextField.text
        if reason == nil || reason!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入事项名称").show()
            return
        }else if dateString == nil {
            Toast(text: "请选择办理时间").show()
            return
        }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        let hud = showHUD(text: "搜索中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.searchWorkList, params: ["userId" : userId , "areaId" : areaId , "workName" : reason! , "submitTime" : dateString!]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.tableData.removeAll()
                    let data = object["data"].arrayValue
                    self?.tableData += data
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
    
    // MARK: - IQDropDownTextFieldDelegate
    func textField(_ textField: IQDropDownTextField, didSelect date: Date?) {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        dateString = format.string(from: date!)
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
