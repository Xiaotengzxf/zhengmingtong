//
//  VerticalViewController.swift
//  RAReorderableLayout-Demo
//
//  Created by Ryo Aoyama on 11/17/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

import UIKit
import RAReorderableLayout
import SwiftyJSON

class VerticalViewController: UIViewController, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    var items : [JSON] = []
    var filterItems : [JSON] = []
    var tag : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.collectionViewLayout = RAReorderableLayout()
        let temp = items
        for (index , item) in temp.enumerated() {
            if let actionType = item["actionType"].int , actionType >= 10 {
                filterItems.append(item)
                items.remove(at: index)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var temp : [JSON] = []
        for var item in items {
            let actionType = item["actionType"].intValue
            if actionType >= 10 {
                item["actionType"].int = actionType - 10
            }
            temp.append(item)
        }
        for var item in filterItems {
            let actionType = item["actionType"].intValue
            if actionType < 10 {
                item["actionType"].int = actionType + 10
            }
            temp.append(item)
        }
        NotificationCenter.default.post(name: Notification.Name(NotificationName.InfoLook.rawValue), object: 2, userInfo: ["items" : temp , "tag" : tag])
    }
    
    // RAReorderableLayout delegate datasource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let threePiecesWidth = floor(screenWidth / 4.0 - ((2.0 / 4) * 2))
        return CGSize(width: threePiecesWidth, height: threePiecesWidth * 8 / 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 2.0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return items.count
        }else {
            return filterItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! MCollectionReusableView
        reusableView.isHidden = indexPath.section == 0
        let count = items.count
        if count > 0 {
            reusableView.label.text = filterItems.count > 0 ? "被隐藏的栏目" : ""
        }
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: section == 0 ?  0 : 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var title = ""
        if let iconImageView = cell.viewWithTag(3) as? UIImageView {
            var name = ""
            if indexPath.section == 0 {
                name = items[indexPath.row]["newsItemIcon"].stringValue
                title = items[indexPath.row]["newsItemName"].stringValue
                
            }else{
                name = filterItems[indexPath.row]["newsItemIcon"].stringValue
                title = filterItems[indexPath.row]["newsItemName"].stringValue
                
            }
            iconImageView.sd_setImage(with: URL(string: NetworkManager.installshared.macAddress() + name), placeholderImage: UIImage(named : "img_default_small"))
        }
        if let deleteImageView = cell.viewWithTag(2) as? UIImageView {
            if indexPath.section == 0 {
                deleteImageView.isHidden = false
            }else {
                deleteImageView.isHidden = true
            }
        }
        if let label = cell.viewWithTag(4) as? UILabel {
            label.text = title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let json = items.remove(at: indexPath.row)
            filterItems.append(json)
        }else{
            let json = filterItems.remove(at: indexPath.row)
            items.append(json)
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, allowMoveAt indexPath: IndexPath) -> Bool {
        if collectionView.numberOfItems(inSection: (indexPath as NSIndexPath).section) <= 1 || indexPath.section > 0 {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, canMoveTo: IndexPath) -> Bool {
        if at.section == 0 && canMoveTo.section > 0 {
            return false
        }
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, at atIndexPath: IndexPath, didMoveTo toIndexPath: IndexPath) {

        let json = items.remove(at: atIndexPath.row)
        items.insert(json, at: toIndexPath.row)
        collectionView.reloadData()
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        return 0
    }
    
    func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(collectionView.contentInset.top, 0, collectionView.contentInset.bottom, 0)
    }
}
