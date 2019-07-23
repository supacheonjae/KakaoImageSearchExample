//
//  MyImagesInfo.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import RealmSwift

/// 내 보관함 내역을 저장하기 위한 Realm의 Object
class MyImagesInfo: Object {
    /// 아이디
    @objc dynamic var thumbnailUrl = ""
    /// 저장 날짜
    @objc dynamic var storeDate = Date()
    
    override static func primaryKey() -> String? {
        return "thumbnailUrl"
    }
    
    override var description: String {
        return "ImageCacheInfo {\(thumbnailUrl), \(storeDate)}"
    }
}
