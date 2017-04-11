//
//  AboutMeViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/7.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class AboutMeViewController: UIViewController {

    @IBOutlet weak var lblCompanyInfo: UILabel!
    @IBOutlet weak var companyIntroLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        companyIntroLabel.text = "北培区市民统一政务信息及应用平台（以下简称：政民通），以市政务信息资源开发利用为主线，通过建设和广大老百姓共享政务资源的多维信息通道，带动市各级机关单位的信息化发展，加速推进城市信息化进程，从而走出一条符合当地客观实际情况、具有当地市政府特色、国内领先的电子政务发展道路。政民通面向的服务对象是市各级行政机关、企事业单位以及市民个人。通过政民通，政府行政单位可以向企业，市民和公务员，发送党务、政务信息，接受广大群众对政府公开、公平、公正三公政策的监督，提供良好的投资环境，提高生产效率；企事业单位可以处理工商税务、年检年审、司法公证以及了解政府投资市场及相关政策等；市民通过政民通，可以接收了解个人税务、公积金、医保社保、子女交流消息，银行账单、水电煤气账单等信息，节约处理家庭事务的时间，提高家庭生活水平。"
        lblCompanyInfo.text = "深圳市北斗星科技有限公司\n电话：86-755-26030864\n传真：86-755-26030864\n地址：深圳市南山区齐民道2号庆邦电子A栋六楼\n邮编：518057\n客服邮箱：service@7stars.net.cn"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
