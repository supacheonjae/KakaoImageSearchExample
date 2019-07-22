//
//  DaumImageFileManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit

/// '내 보관함'에 저장된 파일들을 관리하는 유틸성 싱글톤 클래스
class DaumImageFileManager {
    
    static let shared = DaumImageFileManager()
    
    private let fileManager = FileManager.default
    private let prefix = "daum-images"
    
    private let documentsURL: URL
    
    private init() {
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// 이미지 저장
    ///
    /// - Parameter imageInfo: 저장할 이미지 정보 객체
    /// - Returns: 성공이면 true, 실패이면 false
    func storeImage(imageInfo: ImageInfo) -> StoreError? {
        
        let rootPath = documentsURL
            .appendingPathComponent(prefix)
        
        if !fileManager.fileExists(atPath: rootPath.path) {
            do {
                try fileManager.createDirectory(atPath: rootPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Log.d(output: "디렉터리 생성 실패.. \(error)")
                return .unknown
            }
        }
        
        let fileFullPath = rootPath.appendingPathComponent(imageInfo.fileName)
        
        let data = imageInfo.data
        
        guard !fileManager.fileExists(atPath: fileFullPath.path) else {
            Log.d(output: "\(fileFullPath) 파일이 이미 존재함으로 내 보관함에 저장할 수 없음..")
            return .duplicate
        }
        
        if !fileManager.createFile(atPath: fileFullPath.path, contents: data) {
            Log.d(output: "\(fileFullPath) 파일 생성 실패..")
            return .unknown
        }
        
        return nil
    }
    
    /// 저장된 이미지 탐색 및 반환
    func searchStoredImage(filePath: String) -> UIImage? {
        
        let fileFullPath = documentsURL
            .appendingPathComponent(prefix)
            .appendingPathComponent(filePath)
        
        guard let data = fileManager.contents(atPath: fileFullPath.path) else {
            Log.d(output: "\(fileFullPath) 파일이 존재하지 않음..")
            return nil
        }
        
        return UIImage(data: data)
    }
}
