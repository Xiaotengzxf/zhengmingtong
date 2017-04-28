//
//  CommunityViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Toaster

class CommunityViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var headerViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginTipLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var layoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var imHeightLC: NSLayoutConstraint!
    @IBOutlet weak var imWidthLC: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    var items : [JSON] = []
    let tip = "空空如也，啥子都没有噢！"
    var regexes : [String : String] = [:] // 正则表达式字典
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabPage = TabPageViewController.create()
        let controller1 = EventViewController(nibName: "EventViewController", bundle: nil)
        let controller2 = EventViewController(nibName: "EventViewController", bundle: nil)
        let controller3 = EventViewController(nibName: "EventViewController", bundle: nil)
        let controller4 = EventViewController(nibName: "EventViewController", bundle: nil)
        controller1.tag = 1
        controller2.tag = 2
        controller3.tag = 3
        controller4.tag = 4
        tabPage.tabItems = [(controller1, "待处理"), (controller2, "处理中") , (controller3, "已办结") , (controller4, "草稿箱")]
        var option = TabPageOption()
        option.tabWidth = view.frame.width / CGFloat(tabPage.tabItems.count)
        option.tabHeight = 44
        tabPage.option = option
        self.addChildViewController(tabPage)
        tabPage.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(tabPage.view, belowSubview: emptyView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tabPage]|", options: .directionLeadingToTrailing, metrics: nil, views: ["tabPage" : tabPage.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[headerView]-10-[tabPage]|", options: .directionLeadingToTrailing, metrics: nil, views: ["tabPage" : tabPage.view , "headerView" : headerView]))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommunityViewController.showEmptyView(sender:)))
        tap.numberOfTapsRequired = 1
        emptyView.addGestureRecognizer(tap)
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommunityViewController.handleNotification(sender:)), name: Notification.Name(NotificationName.Commnunity.rawValue), object: nil)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(CommunityViewController.swipe(sender:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(CommunityViewController.swipe(sender:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if userId > 0 {
            let areaId = UserDefaults.standard.integer(forKey: "areaId")
            if areaId > 0 {
                //emptyView.isHidden = true
            }else{
                self.emptyImageView.image = UIImage(named: "empty")
                loginTipLabel.text = "请先选择一个社区"
                emptyView.isHidden = false
            }
            
        }else{
            self.emptyImageView.image = UIImage(named: "empty")
            loginTipLabel.text = "请先登录"
            emptyView.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.Commnunity.rawValue), object: nil)
    }
    
    // MARK: - 自定义方法
    @IBAction func search(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if  userId > 0 {
            let areaId = UserDefaults.standard.integer(forKey: "areaId")
            if areaId > 0 {
                self.performSegue(withIdentifier: "searchcontroller", sender: self)
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
    
    func showEmptyView(sender : UITapGestureRecognizer)  {
        if let content = loginTipLabel.text , content == tip {
            loadData()
            return
        }
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
    
    func loadData() {
        
        let areaId = UserDefaults.standard.integer(forKey: "areaId")
        if areaId > 0 {
            self.emptyView.isHidden = false
            self.emptyImageView.image = UIImage(named: "jiazaizhong")
            self.imWidthLC.constant = 87
            self.imHeightLC.constant = 72
            self.loginTipLabel.text = "加载是件正经事儿，正在走心加载中..."
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.duration = 2
            animation.autoreverses = false
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            self.emptyImageView.layer.add(animation, forKey: "a")
            NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.workTypeList, params: ["areaId" : areaId]) {
                [weak self] (json , error) in
                DispatchQueue.main.async {
                    self?.emptyImageView.layer.removeAllAnimations()
                    self?.emptyView.isHidden = true
                }
                if let object = json {
                    if let result = object["result"].int , result == 1000 {
                        if var data = object["data"].string {
                            data = data.replacingOccurrences(of: "\\\"", with: "\"")
                            data = data.replacingOccurrences(of: "\\r\\n", with: "")
                            data = data.replacingOccurrences(of: "\"}\"", with: "\"}")
                            data = data.replacingOccurrences(of: "]}\"", with: "]}")
                            data = data.replacingOccurrences(of: "\"{\"", with: "{\"")
                            data = data.replacingOccurrences(of: "\\\\", with: "\\")
                            let (json , dic) = self!.regex(data: data)
                            if let dictionary = dic {
                                self?.regexes = dictionary
                            }
                            let value = JSON.parse(json)
                            self!.items.removeAll()
                            self!.items += value.arrayValue
                            
                            self?.collectionView.reloadData()
                            self?.pageControl.numberOfPages = self!.items.count % 4 == 0 ? self!.items.count / 4 : self!.items.count / 4 + 1
                        }
                    }else{
                        DispatchQueue.main.async {
                            self?.emptyView.isHidden = false
                            self?.emptyImageView.image = UIImage(named: "empty")
                            self?.imWidthLC.constant = 55
                            self?.imHeightLC.constant = 43
                            self?.loginTipLabel.text = self?.tip
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.emptyView.isHidden = false
                        self?.emptyImageView.image = UIImage(named: "load_fail")
                        self?.imWidthLC.constant = 87
                        self?.imHeightLC.constant = 72
                        self?.loginTipLabel.text = "世界上最遥远的距离就是没有WIFI...\n请点击屏幕重新加载！"
                    }
                }
            }
        }
    }

    // 处理通知
    func handleNotification(sender : Notification)  {
        let tag = sender.object as? Int ?? 0
        if tag == 1 {
            loadData()
        }else if tag == 2 {
            let info = JSON(sender.userInfo as! [String : Any])
            if let tag = info["state"].int {
                if tag >= 4 {
                    let item = info["item"]
                    let regex = info["regex"].dictionaryObject
                    let images = info["images"].object
                    let index = info["index"].intValue
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "communityevent") as? CommunityEventViewController {
                        controller.item = item
                        controller.regexes = regex as! [String : String]
                        controller.localImages = images as! [String : String]
                        controller.state = info["state"].intValue
                        controller.index = index
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }else{
                    var item = info["item"]
                    var params = item["params"].stringValue
                    params = params.replacingOccurrences(of: "\\\"", with: "\"")
                    params = params.replacingOccurrences(of: "\n", with: "")
                    params = params.replacingOccurrences(of: "\r", with: "")
                    params = params.replacingOccurrences(of: " ", with: "")
                    params = params.replacingOccurrences(of: "\"}\"", with: "\"}")
                    params = params.replacingOccurrences(of: "]}\"", with: "]}")
                    params = params.replacingOccurrences(of: "\"{\"", with: "{\"")
                    params = params.replacingOccurrences(of: "\\\\", with: "\\")
                    let (param , dic) = regex(data: params)
                    let json = JSON.parse(param)
                    item["params"] = json
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "communityevent") as? CommunityEventViewController {
                        controller.item = item
                        controller.regexes = dic!
                        controller.state = info["state"].intValue
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
            
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
                dictionary["aaaaaa\(i)"] = newData.substring(with: newData.index(newData.startIndex, offsetBy: range.location + 9                                                                                                                                                                                                                                                                                                           )..<newData.index(newData.startIndex, offsetBy: range.location + range.length - 1))
                newData = newData.replacingCharacters(in: newData.index(newData.startIndex, offsetBy: range.location)..<newData.index(newData.startIndex, offsetBy: range.location + range.length), with: "\"regex\":\"aaaaaa\(i)\"")
                
            }
            return (newData , dictionary)
        }catch{
            
        }
        return ("" , nil)
    }
    
    func swipe(sender : UISwipeGestureRecognizer) {
        if sender.direction == .down {
            if headerViewLayoutConstraint.constant == -110 {
                headerViewLayoutConstraint.constant = 0
                UIView.animate(withDuration: 0.2, animations: { 
                    [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: { (finished) in
                    
                })
            }
        }else if sender.direction == .up {
            if headerViewLayoutConstraint.constant == 0 {
                headerViewLayoutConstraint.constant = -110
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    self?.view.layoutIfNeeded()
                    }, completion: { (finished) in
                        
                })
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CommunityEventViewController {
            controller.item = items[selectedRow]
            controller.regexes = regexes
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = items.count
        if count > 0 {
            let k = count % 4
            let m = count / 4
            return k > 0 ? (m + 1) * 4 : m * 4
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
            let count = items.count
            if count > 0 {
                if indexPath.row < count {
                    label.text = items[indexPath.row]["WORKTYPENAME"].string
                }else{
                    label.text = nil
                }
            }else{
                label.text = nil
            }
        }
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            let count = items.count
            if count > 0 {
                if indexPath.row < count {
                    imageView.sd_setImage(with: URL(string: items[indexPath.row]["WORKTYPEICON"].stringValue) , placeholderImage: UIImage(named: "img_default_small"))
                }else{
                    imageView.image = nil
                }
            }else{
                imageView.image = nil
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "communityevent", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SCREENWIDTH / 4, height: SCREENWIDTH / 4 * 8 / 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / SCREENWIDTH
        pageControl.currentPage = Int(page)
    }

}
