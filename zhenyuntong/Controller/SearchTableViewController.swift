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
import DZNEmptyDataSet

class SearchTableViewController: UITableViewController , IQDropDownTextFieldDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate {

    @IBOutlet weak var dateTextField: IQDropDownTextField! // 办理时间
    @IBOutlet weak var reasonTextField: UITextField! // 事项名称
    @IBOutlet weak var searchButton: UIButton! // 搜索按钮
    var tableData : [JSON] = []
    var dateString : String?
    var nShowEmpty = 0 // 1 无网络 2 加载中 3  无数据  4 未登录 5 未选择小区
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.dropDownMode = .datePicker
        
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 164)
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
        if (reason == nil || reason!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0) && (dateString == nil) {
            Toast(text: "请输入事项名称或办理时间").show()
            return
        }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        let hud = showHUD(text: "搜索中...")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.searchWorkList, params: ["userId" : userId , "areaId" : areaId , "workName" : reason ?? "" , "submitTime" : dateString ?? ""]){
            [weak self] (json , error) in
            hud.hide(animated: true)
            if let object = json {
                if let result = object["result"].int {
                    self?.tableData.removeAll()
                    if result == 1000 {
                        self?.nShowEmpty = 0
                        
                        let data = object["data"].arrayValue
                        self?.tableData += data
                        
                    }else if result == 1004 {
                        self?.nShowEmpty = 3
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                    self?.tableView.reloadData()
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == dateTextField && dateTextField.date == nil {
            dateTextField.date = Date()
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
            message = "根据当前条件未查询到数据"
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
