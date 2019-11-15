//
//  KakaoTableviewCell.swift
//  ST_Unitas_iOS
//
//  Created by lee on 2019/11/14.
//  Copyright © 2019 lee. All rights reserved.
//

import UIKit

protocol IKakaoTableviewCell {
    func IconClicked(index : Int)
}

class KakaoTableviewCell : UITableViewCell {

    @IBOutlet var thumbnail_url: UIImageView!
    @IBOutlet var collection: UILabel!
    @IBOutlet var site_name: UILabel!
    @IBOutlet var date: UILabel!
    
    public var delegate: IKakaoTableviewCell?
    
    func setDelegate(delegate : IKakaoTableviewCell){
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    @IBAction func IconClicked(_ sender: Any) {
        self.delegate?.IconClicked(index : self.tag)
    }
    
}
