//
//  ImageCell.swift
//  genius-hayun
//
//  Created by 하윤2 on 21/07/2019.
//  Copyright © 2019 하윤2. All rights reserved.
//

import UIKit
import RxSwift

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
