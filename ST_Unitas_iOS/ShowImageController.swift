//
//  ShowImageController.swift
//  ST_Unitas_iOS
//
//  Created by lee on 2019/11/15.
//  Copyright © 2019 lee. All rights reserved.
//

import UIKit
import Kingfisher

class ShowImageController: UIViewController {

    @IBOutlet var original_image: UIImageView!
    public var url : URL!
    
    @IBAction func confirm_clicked(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        NSLog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> \(url.absoluteString)")
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        self.original_image.kf.indicatorType = .activity
        self.original_image.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
    
}
