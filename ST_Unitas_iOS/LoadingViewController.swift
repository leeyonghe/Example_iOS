//
//  LoadingViewController.swift
//  ST_Unitas_iOS
//
//  Created by lee on 2019/11/14.
//  Copyright © 2019 lee. All rights reserved.
//
import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        perform(#selector(passNext), with: nil, afterDelay: 3)
    }

    @objc public func passNext(){
        performSegue(withIdentifier: "next", sender: self)
    }

}
