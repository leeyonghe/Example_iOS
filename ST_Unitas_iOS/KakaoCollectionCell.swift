//
//  KakaoCollectionCell.swift
//  ST_Unitas_iOS
//
//  Created by lee on 2019/11/16.
//  Copyright © 2019 lee. All rights reserved.
//

import UIKit



protocol IKakaoCollectionCell {
    func IconClicked2(index : Int)
}

class KakaoCollectionCell : UICollectionViewCell{

    @IBOutlet var thumbnail_url: UIImageView!
    @IBOutlet var collection: UILabel!
    @IBOutlet var site_name: UILabel!
    @IBOutlet var date: UILabel!
    
    public var delegate: IKakaoCollectionCell?
    
    func setDelegate(delegate : IKakaoCollectionCell){
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    @IBAction func IconClicked(_ sender: Any) {
        self.delegate?.IconClicked2(index : self.tag)
    }
    
}
