//
//  InfoLookTableViewCell.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class InfoLookTableViewCell: UITableViewCell , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var layoutConstraint: NSLayoutConstraint!
    var items : [JSON]?
    var bMore : Bool = false
    var delegate : InfoLookTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if var count = items?.count {
            if count < 8 {
                let k = count % 4
                let m = count / 4
                return k > 0 ? (m + 1) * 4 : (bMore ? m + 1 : m) * 4
            }else{
                count += (bMore ? 1 : 0)
                let k = count % 8
                let m = count / 8
                return k > 0 ? (m + 1) * 8 : m * 8
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
            if let count = items?.count {
                if indexPath.row < count {
                    label.text = items?[indexPath.row]["newsItemName"].string
                }else if indexPath.row == count {
                    label.text = "更多"
                }else{
                    label.text = nil
                }
            }else{
                label.text = nil
            }
        }
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            if let count = items?.count {
                if indexPath.row < count {
                    imageView.sd_setImage(with: URL(string: NetworkManager.installshared.macAddress() + items![indexPath.row]["newsItemIcon"].stringValue), placeholderImage: UIImage(named : "img_default_small"))
                }else if indexPath.row == count {
                    imageView.image = UIImage(named: "ic_add")
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
        if let count = items?.count {
            if indexPath.row < count {
                delegate?.tableViewDidSelectedIndexPathWith(tag: 2, info: ["item" : items![indexPath.row]])
            }else if indexPath.row == count {
                delegate?.tableViewDidSelectedIndexPathWith(tag: 3, info: ["tag" : tag])
            }else{
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREENWIDTH - 3) / 4, height: (SCREENWIDTH - 3) / 4 * 8 / 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 0, 1, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / SCREENWIDTH
        pageControl.currentPage = Int(page)
    }

}

protocol InfoLookTableViewCellDelegate {
    func tableViewDidSelectedIndexPathWith(tag : Int , info : [String : Any])
}
