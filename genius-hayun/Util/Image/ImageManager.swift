//
//  ImageManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

class ImageManager {
    
    private let memoryCache = NSCache<NSString, AnyObject>()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    func loadImage(imageInfo: ImageInfo) {
        
        
        guard let image = memoryCache.object(forKey: imageInfo.thumbNailUrl as NSString) as? UIImage else {
            
            guard let mUrl = URL(string: imageInfo.thumbNailUrl) else {
                imageInfo.rx_image.onNext(nil)
                return
            }
            
            // URL을 통하여 이미지 다운로드 후에 캐시 저장
            downloadImage(from: mUrl) { [unowned self] image, fileName in
                if let image = image {
                    self.memoryCache.setObject(image, forKey: imageInfo.thumbNailUrl as NSString)
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
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
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
}
