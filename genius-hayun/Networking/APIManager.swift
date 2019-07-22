//
//  APIManager.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import Foundation
import RxSwift

class APIManager {
    
    private let API_KEY: String
    
    typealias Parameters = [String : Any]
    
    let disposeBag = DisposeBag()
    
    deinit {
        Log.d(output: "소멸")
    }
    
    init() {
        
        // PList로부터 API 키 가져오기
        guard let url = Bundle.main.url(forResource:"KakaoService_Info", withExtension: "plist") else {
            fatalError("카카오 검색 서비스를 사용할 수 없습니다.")
        }
        
        do {
            let data = try Data(contentsOf:url)
            let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String : Any]
            self.API_KEY = dict["API_KEY"] as! String
        } catch {
            Log.d(output: error)
            fatalError("API 키 정보를 불러올 수 없습니다.")
        }
    }
    
    // get 방식 url + parameter 반환
    private func convertUrl(api: API, with params: Parameters) -> String {
        
        // 파라미터가 없으면 URL 그대로 리턴
        guard params.count > 0 else {
            return api.url
        }
        
        let urlWithParams = params.reduce("\(api.url)?") { result, param in
            
            if let last = result.last, last == "?" {
                return "\(result)\(param.key)=\(param.value)"
                
            } else {
                return "\(result)&\(param.key)=\(param.value)"
            }
        }
        
        guard let convertedURL = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return api.url
        }
        
        return convertedURL
    }
    
    /// 요청 옵저버블 넘겨주고 응답 옵저버블 돌려받음
    func request(requestObservable: Observable<(API, Parameters?)>) -> Observable<(Data?, URLResponse?, Error?)> {
        
        // 서브젝트로 응답 방출
        let resp = PublishSubject<(Data?, URLResponse?, Error?)>()
        
        requestObservable
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [unowned self] api, params in
                
                let convertedUrl = self.convertUrl(api: api, with: params ?? [:])
                
                Log.d(output: "request URL -> \(convertedUrl)")
                
                guard let url = URL(string: convertedUrl) else {
                    Log.d(output: "URL Error occur: \(api.url)")
                    return
                }
                
                let defaultSession = URLSession(configuration: .default)
                
                var request = URLRequest(url: url)
                request.httpMethod = "get"
                request.allHTTPHeaderFields = [
                    "Authorization": self.API_KEY
                ]
                
                let dataTask = defaultSession.dataTask(with: request) { data, response, error in
                    resp.onNext((data, response, error))
                }
                
                dataTask.resume()
                
            })
            .disposed(by: disposeBag)
        
        return resp.asObservable()
    }
    
}

// MARK: - API 목록
extension APIManager {
    
    /// API 목록 정의
    enum API: String {
        
        case searchImage = "image"
        case searchVCLip = "vclip"
        
        var url: String {
            // let server_url = "http://192.168.0.259:8080"
            let server_url = "https://dapi.kakao.com/v2/search/"
            
            return "\(server_url)\(self.rawValue)"
        }
        
    }
}
