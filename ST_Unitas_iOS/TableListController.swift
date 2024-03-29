//
//  TableListController.swift
//  ST_Unitas_iOS
//
//  Created by lee on 2019/11/14.
//  Copyright © 2019 lee. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON
import RxCocoa
import RxSwift

extension UIImage {
    static func imageFromLayer (layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContext(layer.frame.size)
        guard let currentContext = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in: currentContext)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
}

extension UISearchBar {
    func setCustomBackgroundColor (color: UIColor) {
        let backgroundLayer = CALayer()
        backgroundLayer.frame = frame
        backgroundLayer.backgroundColor = color.cgColor
        if let image = UIImage.imageFromLayer(layer: backgroundLayer) {
            self.setBackgroundImage(image, for: .any, barMetrics: .default)
        }
    }
}

class TableListController : UIViewController ,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, IKakaoTableviewCell, IKakaoCollectionCell{
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var empty_bar: UILabel!
    @IBOutlet var loadingview: UIView!
    @IBOutlet var collectionList: UICollectionView!
    @IBOutlet var select_icon: UIImageView!
    
    var data : NSMutableArray!
    var page : Int!
    let threshold = 100.0
    var isLoadingMore : Bool = false
    var is_end : Int = 0
    
    
    override func viewDidLoad() {
        self.data = NSMutableArray.init()
        self.searchBar.setCustomBackgroundColor(color: UIColor.white)
        self.tableView.backgroundColor = UIColor.white
        self.page = 1
        
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 320)
        self.collectionList?.collectionViewLayout = layout
        if select_icon.isHighlighted {
            NSLog("Highlighted")
        }else{
            NSLog("No Highlighted")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.data.count
        if count > 0 {
            self.empty_bar.isHidden = true
        }else{
            self.empty_bar.isHidden = false
        }
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    //              "collection": "news",
    //              "thumbnail_url": "https://search2.kakaocdn.net/argon/130x130_85_c/36hQpoTrVZp",
    //              "image_url": "http://t1.daumcdn.net/news/201706/21/kedtv/20170621155930292vyyx.jpg",
    //              "width": 540,
    //              "height": 457,
    //              "display_sitename": "한국경제TV",
    //              "doc_url": "http://v.media.daum.net/v/20170621155930002",
    //              "datetime": "2017-06-21T15:59:30.000+09:00"

        
        let cellIdentifier = "Cell"
        
        var cell = KakaoTableviewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell as! KakaoTableviewCell
        }
        
        let obj = self.data.object(at: indexPath.row) as! NSDictionary
        
        cell.collection.text = "구분 : \(obj.object(forKey: "collection") as? NSString ?? "")"
        
        cell.site_name.text = "사이트이름 : \(obj.object(forKey: "display_sitename") as? NSString ?? "")"
        
        cell.date.text = "생성일 : \(obj.object(forKey: "datetime") as? String ?? "")"
        
        let url = URL(string: obj.object(forKey: "thumbnail_url") as! String)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        
        cell.thumbnail_url.kf.indicatorType = .activity
        cell.thumbnail_url.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        cell.setDelegate(delegate: self)
        
        cell.tag = indexPath.row
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.data.object(at: indexPath.row) as! NSDictionary
        guard let url = URL(string: obj.object(forKey: "doc_url") as! String) else { return }
        UIApplication.shared.open(url)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.data.object(at: indexPath.row) as! NSDictionary
        guard let url = URL(string: obj.object(forKey: "doc_url") as! String) else { return }
        UIApplication.shared.open(url)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.data.count
        if count > 0 {
            self.collectionList.isHidden = false
            self.empty_bar.isHidden = true
        }else{
            self.collectionList.isHidden = true
            self.empty_bar.isHidden = false
        }
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "CCell"
        
        let cell = collectionList.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! KakaoCollectionCell
        
        let obj = self.data.object(at: indexPath.row) as! NSDictionary
        
        cell.collection.text = "구분 : \(obj.object(forKey: "collection") as? NSString ?? "")"
        
        cell.site_name.text = "사이트이름 : \(obj.object(forKey: "display_sitename") as? NSString ?? "")"
        
        cell.date.text = "생성일 : \(obj.object(forKey: "datetime") as? String ?? "")"
        
        let url = URL(string: obj.object(forKey: "thumbnail_url") as! String)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        
        cell.thumbnail_url.kf.indicatorType = .activity
        cell.thumbnail_url.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
            
        cell.setDelegate(delegate: self)
        
        cell.tag = indexPath.row
        
        return cell
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSLog(">>>>>>>>>>>>>>>>>>> %@", searchText)
        NSLog(">>>>>>>>>>>>>>>>>>> %d", self.data.count)
        
        self.page = 1
        
        if self.data.count > 0 && searchText.isEmpty {
            
            self.empty_bar.isHidden = false
            
            self.tableView.isHidden = true
            self.collectionList.isHidden = true
            
            self.data.removeAllObjects()
            
        } else if !searchText.isEmpty {
            
            self.data.removeAllObjects()
            
            if self.select_icon.isHighlighted {
                self.collectionList.reloadData()
            }else{
                self.tableView.reloadData()
            }
            
            
            let backgroundQueue = DispatchQueue(label: "TableListController", qos: .background)
            backgroundQueue.async {
                self.SearchProcess(searchText: searchText)
            }
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
        if self.select_icon.isHighlighted {
            let  height = self.collectionList.frame.size.height
            let contentYoffset = self.collectionList.contentOffset.y
            let distanceFromBottom = self.collectionList.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                if is_end == 0 {
                    self.page = self.page + 1
    //                SearchProcess(searchText: self.searchBar.text!)
                    let searchText = self.searchBar.text!
                    let backgroundQueue = DispatchQueue(label: "TableListController", qos: .background)
                    backgroundQueue.async {
                        self.SearchProcess(searchText: searchText)
                    }
                }
            }
        }else{
            let  height = self.tableView.frame.size.height
            let contentYoffset = self.tableView.contentOffset.y
            let distanceFromBottom = self.tableView.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                if is_end == 0 {
                    self.page = self.page + 1
    //                SearchProcess(searchText: self.searchBar.text!)
                    let searchText = self.searchBar.text!
                    let backgroundQueue = DispatchQueue(label: "TableListController", qos: .background)
                    backgroundQueue.async {
                        self.SearchProcess(searchText: searchText)
                    }
                    
                    
                    
                }
            }
        }
    }
    
    
    func IconClicked(index: Int) {
        let obj = self.data.object(at: index) as! NSDictionary
        self .performSegue(withIdentifier: "show_image", sender: obj.object(forKey: "image_url") as! String)
    }
    
    
    func IconClicked2(index: Int) {
        let obj = self.data.object(at: index) as! NSDictionary
        self .performSegue(withIdentifier: "show_image", sender: obj.object(forKey: "image_url") as! String)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_image" {
            let si = segue.destination as! ShowImageController
            si.url = URL(string: sender as! String)
        }
    }
    
    func SearchProcess(searchText : String){
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            self.loadingview.isHidden = false
        }
        
        //        HTTP/1.1 200 OK
        //        Content-Type: application/json;charset=UTF-8
        //        {
        //          "meta": {
        //            "total_count": 422583,
        //            "pageable_count": 3854,
        //            "is_end": false
        //          },
        //          "documents": [
        //            {
        //              "collection": "news",
        //              "thumbnail_url": "https://search2.kakaocdn.net/argon/130x130_85_c/36hQpoTrVZp",
        //              "image_url": "http://t1.daumcdn.net/news/201706/21/kedtv/20170621155930292vyyx.jpg",
        //              "width": 540,
        //              "height": 457,
        //              "display_sitename": "한국경제TV",
        //              "doc_url": "http://v.media.daum.net/v/20170621155930002",
        //              "datetime": "2017-06-21T15:59:30.000+09:00"
        //            },
        //            ...
        //          ]
        //        }
                
        let url = URL(string: "https://dapi.kakao.com/v2/search/image")!
        
        let headers = ["Authorization": "KakaoAK 77a9306101b5e16ed249a11a6d2a2b39"]
        
        NSLog(">>>>>>>>>>>>>>>> searchText \(searchText) ")
        
        Alamofire.request(url,
                          method: .get,
                          parameters: ["query": "\(searchText)", "sort": "recency", "page" : self.page as Int, "size" : 30],
                          headers: headers)
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(String(describing:response.result.error))")
                self.loadingview.isHidden = true
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("No Data")
                self.loadingview.isHidden = true
                return
            }
            
            let json = JSON(value)

            self.data.addObjects(from: json["documents"].arrayObject!)

            self.is_end = json["meta"]["is_end"].intValue

            DispatchQueue.main.async {
                
                if self.select_icon.isHighlighted {
                    self.tableView.isHidden = true
                    self.collectionList.isHidden = false
                    self.collectionList.reloadData()
                }else{
                    self.tableView.isHidden = false
                    self.collectionList.isHidden = true
                    self.tableView.reloadData()
                }
                
                self.loadingview.isHidden = true
            }
            
            semaphore.signal()
            
        }
        
        semaphore.wait()
        
    }
    
    @IBAction func select_btn_clicked(_ sender: Any) {
        self.page = 1
        if self.select_icon.isHighlighted {
            self.select_icon.isHighlighted = false
        }else{
            self.select_icon.isHighlighted = true
        }
        let searchText = self.searchBar.text!
        let backgroundQueue = DispatchQueue(label: "TableListController", qos: .background)
        backgroundQueue.async {
            self.SearchProcess(searchText: searchText)
        }
    }
    
}
