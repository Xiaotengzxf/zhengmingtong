//
//  CollectionViewHorizontalLayout.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/8.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class CollectionViewHorizontalLayout: UICollectionViewFlowLayout {

    var itemCountForRow = 4
    var rowCount = 0
    var allAttributes : [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        for i in 0..<count {
            let indexPath = IndexPath(item: i, section: 0)
            let attributes = self.layoutAttributesForItem(at: indexPath)
            allAttributes.append(attributes!)
        }
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let item = indexPath.item
        var x = 0
        var y = 0
        targetPositionWithItem(item: item, x: &x, y: &y)
        let item2 = originItem(x: x, y: y)
        let nIndexPath = IndexPath(item: item2 , section: indexPath.section)
        let attr = super.layoutAttributesForItem(at: nIndexPath)
        attr?.indexPath = indexPath
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var tem : [UICollectionViewLayoutAttributes] = []
        for attr in attributes! {
            for attr2 in allAttributes {
                if attr.indexPath.item == attr2.indexPath.item {
                    tem.append(attr2)
                    break
                }
            }
        }
        return tem
    }
    
    func targetPositionWithItem(item : Int , x : inout Int , y : inout Int) {
        let page = item / (itemCountForRow * rowCount)
        x = item % itemCountForRow + page * itemCountForRow
        y = item / itemCountForRow - page * rowCount
    }
    
    func originItem(x : Int , y : Int) -> Int {
        return x * rowCount + y
    }
    
}
