//
//  RealmManager+MyImagesInfo.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import RealmSwift

extension RealmManager {
    
    /// 이미 가지고 있는 이미지인지 판별해주는 메서드
    ///
    /// - Returns: 소유하고 있는 이미지면 true, 아니면 false
    func hasImage(urlStr: String) -> Bool {
        if let _ = getImageInfo(urlStr: urlStr) {
            return true
        } else {
            return false
        }
    }
    
    /// 내 보관함의 특정 이미지 정보를 가져오는 메서드
    ///
    /// - Parameter urlStr: URL 주소 문자열
    /// - Returns: 반환 값이 nil이라면 urlStr의 이미지는 내 보관함에 존재하지 않는 이미지임
    func getImageInfo(urlStr: String) -> MyImagesInfo? {
        return realm.objects(MyImagesInfo.self)
            .filter("thumbnailUrl == %@", urlStr)
            .first
    }
    
    /// 내 보관함의 모든 이미지 정보들을 가져오는 메서드
    ///
    /// - Returns: 내 보관함에 저장 모든 이미지 정보를 가져옴
    func getAllImageInfos() -> Results<MyImagesInfo> {
        return realm.objects(MyImagesInfo.self).sorted(byKeyPath: "storeDate", ascending: false)
    }
    
    /// 이미지 정보를 저장하는 메서드
    ///
    /// 이미지를 저장소에 성공적으로 저장하였을 때만 호출해주세요!
    /// thumbnailUrl와 filePath가 빈 문자열이면 정보 저장을 하지 않습니다.
    ///
    /// - Parameter imageInfo: 이미지 정보 객체
    func storeImageInfo(imageInfo: MyImagesInfo) {
        
        if imageInfo.thumbnailUrl.isEmpty || imageInfo.filePath.isEmpty {
            return
        }
        
        try! realm.write {
            realm.add(imageInfo)
        }
    }
}
