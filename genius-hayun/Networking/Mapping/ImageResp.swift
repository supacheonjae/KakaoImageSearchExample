//
//  ImageResp.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import ObjectMapper

class ImageResp: Mappable {
    
    var is_end: Bool!
    var documents: [ImageDocuments] = []
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        is_end <- map["meta.is_end"]
        documents <- map["documents"]
    }
    
}

class ImageDocuments: Mappable {
    
    var thumbnail_url: String!
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
        
        thumbnail_url <- map["thumbnail_url"]
        datetime <- (map["datetime"], transform)
    }
    
}
