//
//  ImageManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

/// 이미지를 관리하고 로드하는 이미지 관리 클래스
///
/// URL 기반의 퍼사드 패턴의 유틸성 이미지 클래스입니다.
/// 캐시에 존재하는 이미지를 로드할 경우 캐시 이미지를 사용합니다.
class ImageManager {
    
    /// 이미지 저장용 캐시
    ///
    /// 키 값으로 URL 문자열을 사용합니다.
    private let memoryCache = NSCache<NSString, AnyObject>()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    /// 이미지 로드를 시도하는 메서드
    ///
    /// 이미지 로드가 성공한다면 이미지(UIImage)는 imageInfo.rx_image를 통하여 발행됩니다.
    ///
    /// - Parameter imageInfo: 이미지를 불러올 주소를 갖고 있는 ImageInfo
    func loadImage(imageInfo: ImageInfo) {
        
        // 캐시에 있나요?
        guard let image = memoryCache.object(forKey: imageInfo.thumbNailUrl as NSString) as? UIImage else {
            // 캐시에 없습니다..
            
            guard let mUrl = URL(string: imageInfo.thumbNailUrl) else {
                imageInfo.rx_image.onNext(nil)
                return
            }
            
            // URL을 통하여 이미지 다운로드 후에 캐시 저장
            downloadImage(from: mUrl) { [weak self] image, fileName in
                if let image = image {
                    self?.memoryCache.setObject(image, forKey: imageInfo.thumbNailUrl as NSString)
                }
                
                // 확장자 변경
                if fileName.hasSuffix("jpeg") || fileName.hasSuffix("jpg") {
                    imageInfo.imgType = .jpg
                } else if fileName.hasSuffix("png") {
                    imageInfo.imgType = .png
                }
                
                imageInfo.rx_image.onNext(image)
            }
            
            return
        }
        
        // 캐시에서 가져옵니다!!
        imageInfo.rx_image.onNext(image)
        
    }
    
    /// URL을 통하여 UIImage 로드를 시도
    ///
    /// completeHandler 매개 변수의 String에는
    /// 응답 값으로 추천받은 파일명(없다면 요청 URL의 마지막 Path부분)이 들어갑니다.
    private func downloadImage(from url: URL, completeHandler: @escaping (UIImage?, String) -> ()) {
        Log.d(output: "Download Started")
        
        getData(from: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            let fileName = response?.suggestedFilename ?? url.lastPathComponent
            Log.d(output: "\(fileName) Download Finished")
            
            DispatchQueue.main.async() {
                completeHandler(UIImage(data: data), fileName)
            }
        }
    }
    
    /// URL을 통하여 Data 로드를 시도
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
