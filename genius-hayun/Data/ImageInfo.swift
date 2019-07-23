//
//  ImageInfo.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit

/// 이미지 정보 객체
///
/// 이 앱 VC, VM 등에서 통용되는 이미지에 대한 정보를 정의했습니다.
class ImageInfo {

    var thumbNailUrl: String
    
    /// 등록일
    ///
    /// 검색 화면에서는 게시물 등록 날짜,
    /// 내 보관함에서는 보관함에 저장한 날짜를 저장해주세요.
    var date: Date
    
    init(thumbNailUrl: String, date: Date) {
        self.thumbNailUrl = thumbNailUrl
        self.date = date
    }
}
