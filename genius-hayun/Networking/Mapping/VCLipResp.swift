//
//  VCLipResp.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import ObjectMapper

class VCLipResp: Mappable {
    
    var is_end: Bool!
    var documents: [VCLipDocuments] = []
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        is_end <- map["meta.is_end"]
        documents <- map["documents"]
    }
    
}

class VCLipDocuments: Mappable {
    
    /// 썸네일 URL
    var thumbnail: String!
    /// 게시물 등록 날짜
    var datetime: Date?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        let transform = TransformOf<Date, String> (
            fromJSON: { (value: String?) -> Date? in
                guard let dateStr = value else { return nil }
                
                return DateConverter.shared.iso8601Date(from: dateStr)
            },
            toJSON: { (value: Date?) -> String? in
                guard let date = value else { return nil }
                
                return DateConverter.shared.iso8601String(from: date)
            }
        )
        
        thumbnail <- map["thumbnail"]
        datetime <- (map["datetime"], transform)
    }
    
}
