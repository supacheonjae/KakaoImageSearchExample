//
//  RealmManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import RealmSwift

/// 이 앱의 Realm을 관리하는 클래스
///
/// 관리되는 테이블 또는 섹션이 적기때문에 싱글톤으로 관리합니다.
class RealmManager {
    
    /// RealmManager 싱글톤 객체
    static var instance = RealmManager()
    /// Realm 객체
    lazy var realm = self.getRealm()
    
    private init() { }
    
    /// Realm 객체를 새로 생성하여 반환
    private func getRealm() -> Realm {
        return try! Realm()
    }
}
