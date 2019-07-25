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
/// URL 기반의 퍼사드 패턴의 이미지 관리 클래스입니다.
/// 캐시에 존재하는 이미지를 로드할 경우 캐시 이미지를 사용합니다.
class ImageManager {
    
    /// 이미지 저장용 캐시
    ///
    /// 키 값으로 URL 문자열을 사용합니다.
    private static let memoryCache = NSCache<NSString, UIImage>()
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    /// 이미지 매니저의 생성자
    ///
    /// 매개변수 disposeBag과 memoryCache의 생명을 같이 합니다.
    /// - Parameter disposeBag: memoryCache의 생명주기를 설정할 disposeBag,
    ///                         nil이면 cache는 계속 유지됩니다.
    required init(disposeBag: DisposeBag?) {
        
        guard let disposeBag = disposeBag else {
            return
        }
        
        PublishSubject<Void>()
            .subscribe(onDisposed: { [unowned self] in
                self.close()
            })
            .disposed(by: disposeBag)
    }
    
    /// 이미지 로드를 시도하는 메서드
    ///
    /// - Parameter urlStr: 이미지를 불러올 URL
    /// - Returns: urlStr로 이미지 요청 시 결과에 응답하는 옵저버블
    func loadImage(urlStr: String) -> Observable<(image: UIImage?, hasCache: Bool)> {
        
        guard let mUrl = URL(string: urlStr) else {
            return Observable.empty()
        }
        
        // 캐시에 있나요?
        guard let image = ImageManager.memoryCache.object(forKey: urlStr as NSString) else {
            // 캐시에 없습니다..
            
            let pub_image = PublishSubject<UIImage?>()
            // URL을 통하여 이미지 다운로드 후에 캐시 저장
            self.downloadImage(from: mUrl) { downloadedImg in
                
                if let img = downloadedImg {
                    ImageManager.memoryCache.setObject(img, forKey: urlStr as NSString)
                }
                pub_image.onNext(downloadedImg)
            }
            
            return pub_image.map { ($0, false) }
        }
        
        // 캐시에 있는 이미지를 사용합니다!!
        return Observable.just((image, true))
    }
    
    /// URL을 통하여 UIImage 로드를 시도
    private func downloadImage(from url: URL, completeHandler: @escaping (UIImage?) -> ()) {
        Log.d(output: "Download Started")
        
        getData(from: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            let fileName = response?.suggestedFilename ?? url.lastPathComponent
            Log.d(output: "\(fileName) Download Finished")
            
            DispatchQueue.main.async() {
                completeHandler(UIImage(data: data))
            }
        }
    }
    
    /// URL을 통하여 Data 로드를 시도
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /// 캐시를 비워줍니다.
    private func close() {
        Log.d(output: "캐시 초기화!")
        ImageManager.memoryCache.removeAllObjects()
    }
}
