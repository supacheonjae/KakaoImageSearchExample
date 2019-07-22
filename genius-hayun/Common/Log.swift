//
//  Log.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation

/// 로그 클래스
class Log {
    
    /// 로그 출력 허용
    static private let isDebug = true
    
    private init() {}
    
    /// 현재 라인에 대한 간략한 정보와 호출 시간, 사용자가 원하는 출력값 출력
    static func d(filename: String = #file, line: Int = #line, funcname: String = #function, output: Any...) {
        
        guard isDebug else {
            return
        }
        
        print("[\(NSDate().description)] [\(filename)] [\(funcname)][Line \(line)]: \(output)")
    }
}
