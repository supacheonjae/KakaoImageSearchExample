//
//  Enum.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation

// 저장 성공 또는 에러 여부 정의
enum StoreError: CustomStringConvertible {
    case duplicate
    case unknown
    
    var description: String {
        switch self {
        case .duplicate:
            return "이미 보관함에 존재하는 이미지입니다."
        case .unknown:
            return "알 수 없는 오류가 발생하였습니다."
        }
    }
}


// 앨범에 저장 성공 또는 에러 여부 정의
enum SendAlbumError: CustomStringConvertible {
    case unknown
    
    var description: String {
        switch self {
        case .unknown:
            return "알 수 없는 오류가 발생하였습니다."
        }
    }
}
