//
//  CommentTableViewController.swift
//  Test
//
//  Created by 张晓飞 on 2016/12/16.
//  Copyright © 2016年 gemdale. All rights reserved.
//

import UIKit
import WebKit
import Toaster
import MJRefresh
import SwiftyJSON
import IQKeyboardManagerSwift

class CommentTableViewController: UITableViewController , WKUIDelegate , WKNavigationDelegate{
    
    @IBOutlet weak var bbi1: UIBarButtonItem!
    @IBOutlet weak var bbi2: UIBarButtonItem!
    @IBOutlet weak var bbi3: UIBarButtonItem!
    @IBOutlet weak var bbi4: UIBarButtonItem!
    @IBOutlet weak var bbi5: UIBarButtonItem!
    @IBOutlet weak var headerView: UIView!
    var linkUrl : String?
    var imageUrl : String?
    var page = 0
    var adId = 0
    var items : [JSON] = []
    var isZan = false
    var isFavorities = false
    var isCanReply = false
    var commentView : CommentView?
    var webView : WKWebView!
    var progressView : UIProgressView!
    var singleTap = true
    var newDetail : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT - 64), configuration: config)
        if let url = URL(string: linkUrl ?? "") {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
            webView.load(request)
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.sizeToFit()
        headerView.addSubview(webView)
        loadData()
        loadNewsData()
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
        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 44)
        
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 4))
        progressView.progressTintColor = UIColor.orange
        self.view.addSubview(progressView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(CommentTableViewController.keyboardWillShow(sender:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentTableViewController.handleNotification(sender:)), name: Notification.Name(NotificationName.Comment.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentView?.removeFromSuperview()
        commentView = nil
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    [weak self] in
                    self?.progressView.alpha = 0
                    }, completion: {[weak self] (finished) in
                        self?.progressView.setProgress(0, animated: false)
                })
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: - 自定义方法
    func loadData() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.commentList, params: ["newsId" : adId , "pageIndex" : page , "userId" : userId]){
            [weak self] (json , error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    if let data = object["data"].array {
                        self?.items += data
                        if data.count < 20 {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                    self?.tableView.reloadData()
                }else{
                    if let result = object["result"].int , result == 1004 {
                        
                    }else{
                        if let message = object["msg"].string , message.characters.count > 0 {
                            Toast(text: message).show()
                        }
                    }
                    
                }
            }else{
                print(error?.localizedDescription ?? "")
                Toast(text: "网络出错，请检查网络").show()
            }
        }
    }
    
    func loadNewsData() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.getNewsDetails, params: ["newsId" : adId , "userId" : userId]){
            [weak self] (json , error) in
            if let object = json {
                if let result = object["result"].int , result == 1000 {
                    self?.newDetail = object["data"]
                    self?.isZan = object["data" , "isZan"].intValue > 0
                    self?.isFavorities = object["data" , "isFavorites"].intValue > 0
                    self?.isCanReply = object["data" , "isCanReply"].intValue > 0
                    self?.bbi3.image = UIImage(named : self!.isFavorities ? "icon_menu_like_checked" : "icon_menu_like")
                    self?.bbi5.image = UIImage(named: self!.isZan ? "icon_zaned" : "icon_zan")
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

    // 底部工具条事件
    @IBAction func doEvent(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        if userId <= 0 {
            Toast(text: "暂未登录").show()
            return
        }
        if let bar = sender as? UIBarButtonItem {
            switch bar.tag {
            case 1:
                print(1)
            case 2:
                if isCanReply {
                    if commentView != nil {
                        commentView?.isHidden = false
                        commentView?.textField.becomeFirstResponder()
                    }else{
                        commentView = Bundle.main.loadNibNamed("CommentView", owner: nil, options: nil)?.first as? CommentView
                        commentView?.translatesAutoresizingMaskIntoConstraints = false
                        commentView?.textField.becomeFirstResponder()
                        self.view.window?.addSubview(commentView!)
                        self.view.window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[commentView(width)]", options: .directionLeadingToTrailing, metrics: ["width" : SCREENWIDTH], views: ["commentView" : commentView!]))
                        self.view.window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[commentView(height)]|", options: .directionLeadingToTrailing, metrics: ["height" : SCREENHEIGHT - 64], views: ["commentView" : commentView!]))
                    }
                }else{
                    Toast(text:"该新闻暂不支持评论。").show()
                }
            case 3:
                if !singleTap {
                    return
                }
                singleTap = false
                let userId = UserDefaults.standard.integer(forKey: "userId")
                let hud = showHUD(text: "加载中...")
                NetworkManager.installshared.request(type: .post, url: isFavorities ? NetworkManager.installshared.cancelFavorite : NetworkManager.installshared.favorite, params: ["userId" : userId , "newsId" : adId]){
                    [weak self] (json , error) in
                    self?.singleTap = true
                    hud.hide(animated: true)
                    if let object = json {
                        if let result = object["result"].int , result == 1000 {
                            self!.isFavorities = !self!.isFavorities
                            Toast(text: self!.isFavorities ? "收藏成功" : "取消收藏成功").show()
                            self?.bbi3.image = UIImage(named : self!.isFavorities ? "icon_menu_like_checked" : "icon_menu_like")
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        Toast(text: self!.isFavorities ? "取消收藏失败" : "收藏失败").show()
                    }
                }
            case 4:
                print(4)
                // 1.创建分享参数
                let shareParames = NSMutableDictionary()
                var imgUrl = ""
                if imageUrl != nil {
                    imgUrl = imageUrl!
                    if !imgUrl.hasPrefix("http") {
                        imgUrl = "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=" + imgUrl
                    }
                }else{
                    imgUrl = newDetail?["imgUrl"].string ?? "http://www.mob.com/images/logo_black.png"
                    if !imgUrl.hasPrefix("http") {
                        imgUrl = "http://120.77.56.220:8080/BBV3Web/flashFileUpload/downloadHandler.do?fileId=" + imgUrl
                    }
                }
                shareParames.ssdkSetupShareParams(byText: "\(newDetail?["summary"].string ?? "暂无内容")",
                    images : "\(imageUrl != nil ? imageUrl! : newDetail?["imgUrl"].string ?? "http://www.mob.com/images/logo_black.png")",
                                                  url : NSURL(string:self.linkUrl!) as URL!,
                                                  title : "\(newDetail?["title"].string ?? "暂无标题")",
                                                  type : SSDKContentType.auto)
                ShareSDK.showShareActionSheet(self.view, items: nil, shareParams: shareParames, onShareStateChanged: { (state, type, content, entity, error, finished) in
                    switch state{
                        
                    case SSDKResponseState.success: print("分享成功")
                    case SSDKResponseState.fail:    print("授权失败,错误描述:\(error)")
                    case SSDKResponseState.cancel:  print("操作取消")
                        
                    default:
                        break
                    }
                })
            case 5:
                if !singleTap {
                    return
                }
                singleTap = false
                let userId = UserDefaults.standard.integer(forKey: "userId")
                let hud = showHUD(text: "加载中...")
                NetworkManager.installshared.request(type: .post, url: isFavorities ? NetworkManager.installshared.cancelZan : NetworkManager.installshared.zan, params: ["userId" : userId , "newsId" : adId]){
                    [weak self] (json , error) in
                    hud.hide(animated: true)
                    self?.singleTap = true
                    if let object = json {
                        if let result = object["result"].int , result == 1000 {
                            self!.isZan = !self!.isZan
                            Toast(text: self!.isZan ? "点赞成功" : "取消点赞成功").show()
                            self?.bbi5.image = UIImage(named: self!.isZan ? "icon_zaned" : "icon_zan")
                        }else{
                            if let message = object["msg"].string , message.characters.count > 0 {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        Toast(text: self!.isZan ? "取消点赞失败" : "点赞失败").show()
                    }
                }

            default:
                fatalError()
            }
        }
    }
    
    // 键盘显示
    func keyboardWillShow(sender : Notification) {
        if let duration = sender.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            if let endFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                commentView?.showWithKeyboard(height: endFrame.cgRectValue.size.height, duration: duration)
            }
        }
    }
    
    // 键盘隐藏
    func keyboardWillHide(sender : Notification) {
        if let duration = sender.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            commentView?.hideWithKeyboard(duration: duration)
        }
    }
    
    // 处理通知
    func handleNotification(sender : Notification) {
        if let tag = sender.object as? Int {
            if tag == 1 {
                if let dictionary = sender.userInfo as? [String : String] {
                    let userId = UserDefaults.standard.integer(forKey: "userId")
                    let hud = showHUD(text: "加载中...")
                    NetworkManager.installshared.request(type: .post, url: NetworkManager.installshared.comment , params: ["userId" : userId , "newsId" : adId , "content" : dictionary["content"] ?? ""]){
                        [weak self] (json , error) in
                        hud.hide(animated: true)
                        if let object = json {
                            if let result = object["result"].int , result == 1000 {
                                self!.isFavorities = !self!.isFavorities
                                Toast(text: "评论成功").show()
                                self?.commentView?.textField.text = nil
                                self?.commentView?.isHidden = true
                                self?.tableView.mj_header.beginRefreshing()
                                
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
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let json = items[indexPath.row]
        if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
            imageView.sd_setImage(with: URL(string: NetworkManager.installshared.macAddress() + json["user" , "header"].stringValue), placeholderImage: UIImage(named: "img_default_big"))
        }
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = json["user" , "nickName"].string
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            if let date = json["replyTime"].string , date.characters.count > 10 {
                label.text = date.substring(to: date.index(date.startIndex, offsetBy: 10))
            }
        }
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            label.text = json["content"].string
        }
        cell.selectionStyle = .none
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.offsetHeight;", completionHandler:{[weak self] (result , error) in
            print("高度\(result)")
            if var height = result as? CGFloat {
                let scrollHeight = webView.scrollView.contentSize.height
                if scrollHeight > height {
                    height = scrollHeight
                }
                webView.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: height)
                self?.headerView.frame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: height + 44)
                self?.tableView.tableHeaderView = self!.headerView
            }
            
        })
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
