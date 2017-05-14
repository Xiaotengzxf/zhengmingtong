//
//  NetworkManager.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let installshared = NetworkManager()
    
    let install = "user/install" // 安装接口
    let regist = "user/regist" // 注册接口
    let login = "user/login" // 登录接口
    let getNewsItem = "news/getNewsItem" // 获取查阅信息的栏目
    let getNewsByItem = "news/getNewsByItem" // 根据消息栏目获取消息列表
    let getNewsDetails = "news/getNewsDetails" // 新闻详情
    let favorite = "news/favorite" // 新闻收藏
    let cancelFavorite = "news/cancelFavorite" // 取消收藏
    let zan = "news/zan" // 新闻点赞
    let cancelZan = "news/cancelZan" // 取消点赞
    let comment = "news/comment" // 新闻评论
    let commentList = "news/commentList" // 新闻评论列表
    let workTypeList = "work/workTypeList" // 事项类型清单
    let handleWork = "work/handleWork" // 在线办理
    let workList = "work/workList" // 办理的事项清单
    let searchWorkList = "work/searchWorkList" // 搜索办理的事项清单
    let cancelWork = "work/cancelWork" // 终止办理
    let ereaList = "area/areaList" // 获取社区列表
    let focusErea = "area/focusErea" // 添加关注社区
    let cancelErea = "area/cancelErea" // 取消关注社区
    let myFocusEreas = "area/myFocusEreas" // 我关注社区列表
    let getSession = "chat/getSession" // 消息获取会话
    let syncMsgBySession = "chat/syncMsgBySession" // 同步回话消息（非公告）
    let getMsgByPull = "chat/getMsgByPull" // 下拉获取消息记录（非公告）
    let sendText = "chat/sendText" // 发送文字信息
    let sendFileMsg = "chat/sendFileMsg" // 发送文件信息
    let msgRead = "chat/msgRead" // 消息标记为已读
    let getUnReadMsgCount = "chat/getUnReadMsgCount" // 获取未读消息总数
    let modifyPassword = "user/modifyPassword" // 修改密码
    let findPassword = "user/findPassword" // 找回密码
    let modifyHeader = "user/modifyHeader" // 修改头像
    let modifyNickName = "user/modifyNickName" // 修改昵称
    let authentication = "user/authentication" // 实名认证
    let myFavourite = "user/myFavourite" // 我的收藏
    let feedback = "user/feedback" // 意见反馈
    let checkUpdate = "sync/checkUpdate" // 检查更新
    let offlineRead = "sync/offlineRead" // 离线阅读
    let syncSystemMsg = "chat/syncSystemMsg" // 系统消息
    let pullSystemMsg = "chat/pullSystemMsg" // 系统消息下拉
    let submit = "work/submit"
    let modify = "work/modify"
    let getQuestions = "laveMsg/getQuestions"
    let getQuestionDet = "laveMsg/getQuestionDet"
    let saveQuestion = "laveMsg/saveQuestion"
    let reply = "laveMsg/reply"
    
    
    func macAddress() -> String {
        if let mac = UserDefaults.standard.string(forKey: "mac") {
            return mac
        }else{
            return "http://120.24.254.101:8080"
        }
    }
    
    func request(type : HTTPMethod , url : String , params : Parameters? , callback : @escaping (JSON? , Error?)->())  {
        print("\(macAddress())/bbServer/\(url)")
        Alamofire.request(macAddress() + "/bbServer/" + url, method: type, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let json = response.result.value {
                print(json)
                let object = JSON(json)
                callback(object, nil)
            }else{
                callback(nil , response.result.error)
            }
        }
    }
    
    func requestWithSession(callback : @escaping (_ data : Data?) -> ()) {
        let request = URLRequest(url: URL(string : "http://img3.imgtn.bdimg.com/it/u=3946772086,3737738661&fm=21&gp=0.jpg")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(data)
        }
        task.resume()
    }
}

