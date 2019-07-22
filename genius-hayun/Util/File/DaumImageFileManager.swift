//
//  DaumImageFileManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit

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
                return .unknown
            }
        }
        
        let fileFullPath = rootPath.appendingPathComponent(imageInfo.fileName)
        
        print(fileFullPath)
        
        let data = imageInfo.data
        
        guard !fileManager.fileExists(atPath: fileFullPath.path) else {
            return .duplicate
        }
        
        if !fileManager.createFile(atPath: fileFullPath.path, contents: data) {
            return .unknown
        }
        
        return nil
    }
    
    /// 저장된 이미지 탐색 및 반환
    func searchStoredImage(filePath: String) -> UIImage? {
        
        let fileFullPath = documentsURL
            .appendingPathComponent(prefix)
            .appendingPathComponent(filePath)
        
        print(fileFullPath.path)
        
        guard let data = fileManager.contents(atPath: fileFullPath.path) else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
