//
//  mTabBarController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/12.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class mTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: Notification.Name("TabBarController"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleNotification(notification : Notification) {
        if let badge = notification.object as? Int {
            self.tabBar.items?[3].badgeValue = badge > 0 ? "\(badge)" : nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
