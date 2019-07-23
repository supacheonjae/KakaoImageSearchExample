//
//  DaumSearchCollectionViewLayout.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//
//  https://www.raywenderlich.com/392-uicollectionview-custom-layout-tutorial-pinterest 참조함
//

import UIKit

class DaumSearchCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: DaumSearchCollectionViewLayoutDelegate!
    
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    
    // 다시 계산하지 않도록..
    fileprivate var beforeCount = 0
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    // 사진이 추가될 때마다 증가
    fileprivate var contentHeight: CGFloat = 0
    
    // 내용물에 따라 계산
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // 내용물 크기 반환
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // xOffset, yOffset들 초기화
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // 이미지 재검색이라면 캐시 초기화
        if beforeCount > collectionView.numberOfItems(inSection: 0) {
            cache = []
            contentHeight = 0
        }
        beforeCount = collectionView.numberOfItems(inSection: 0)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 프레임 계산
            let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) // FIXME: Rx기반이라 비동기 방식으로 높이를 가져와야 하는데.. 커스텀 RxDataSource에 각 아이템의 높이를 계산해주는 Delegate 구현하였지만 문제는 이미지 다운로드 완료 시점도 비동기라는거..
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // UICollectionViewLayoutAttributes 캐시 추가
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 높이 확장
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}

// 높이 계산 대리자
protocol DaumSearchCollectionViewLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}
