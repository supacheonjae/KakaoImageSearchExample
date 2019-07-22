//
//  HomeVC.swift
//  genius-hayun
//
//  Created by 하윤2 on 20/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeVC: ViewController {

    @IBOutlet weak var tableView: UITableView!
    
    typealias SubVCInfo = (title: String, storyboardID: String)
    
    private let subVCList = [
        SubVCInfo(title: "검색", storyboardID: "SearchVC"),
        SubVCInfo(title: "내 보관함", storyboardID: "MyImagesVC")
    ]
    
    
    deinit {
        Log.d(output: "소멸")
    }
    
    // MARK: - 초기화 관련
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()
        
    }
    
    /// Rx 바인딩
    private func setupRx() {
        
        let rx_subVCList = Observable.just(subVCList).asDriver(onErrorJustReturn: [])
        
        // TableView 바인딩
        rx_subVCList
            .drive(tableView.rx.items(cellIdentifier: "MenuCell", cellType: MenuCell.self)) { (idxPath, subVC, cell) in
                // 하위 VC 별 셀 정의
                cell.lbl_title.text = subVC.title
            }
            .disposed(by: disposeBag)
        
        // TableView Select 바인딩
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(SubVCInfo.self))
            .subscribe(onNext: { [unowned self] idxPath, subVC in
                
                self.tableView.deselectRow(at: idxPath, animated: true)
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: subVC.storyboardID) else {
                    return
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - 네비게이션 관련
    // IB의 Exit(Navigation Controller의 pop)기능을 사용하기 위한 IBAction
    @IBAction func backToHomeVC(segue: UIStoryboardSegue) {
        Log.d(output: "Back to HomeVC")
    }
}