//
//  StartViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/15.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var startImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startImageView.frame.origin = CGPoint(x: SCREENWIDTH / 2, y: SCREENHEIGHT / 2)
        UIView.animate(withDuration: 2, animations: {
            [weak self] in
            self?.startImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: {[weak self] (finished) in
                if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? mTabBarController {
                    controller.modalTransitionStyle = .crossDissolve
                    self?.present(controller, animated: true, completion: { 
                        
                    })
                    
                }
        })
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
