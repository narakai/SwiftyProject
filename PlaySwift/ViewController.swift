//
//  ViewController.swift
//  PlaySwift
//
//  Created by leon on 16/1/16.
//  Copyright © 2016年 Clem. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UITableViewController {
//    var data = DataModel()
    var photos = [PhotoInfo]()
    private var bgColor = UIColor()
    private var txtColor = UIColor()

    override func viewDidLoad() {
        super.viewDidLoad()

        //init
        refreshControl = UIRefreshControl()
        //        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!);

        if let loadedPhotos = FMDBHelper.loadData() {
            if !loadedPhotos.isEmpty {
                photos = loadedPhotos
                let randomIndex = Int(arc4random_uniform(UInt32(photos.count)))
                print("random index is \(randomIndex)")
                let randomIndexUrl = photos[randomIndex].url


                if let image = UIImage(named: "testPic") {
                    let colors = image.getColors(CGSize(width: 100, height: 100))
                    //            let colors = image.getColors()
                    bgColor = colors.backgroundColor
                    txtColor = colors.primaryColor
                    self.navigationController?.navigationBar.barTintColor = colors.secondaryColor
                    self.navigationController?.navigationBar.translucent = false;
                }

                tableView.reloadData()
            } else {
                if let image = UIImage(named: "testPic") {
                    let colors = image.getColors(CGSize(width: 100, height: 100))
                    //            let colors = image.getColors()
                    bgColor = colors.backgroundColor
                    txtColor = colors.primaryColor
                    self.navigationController?.navigationBar.barTintColor = colors.secondaryColor
                    self.navigationController?.navigationBar.translucent = false;
                }
            }

        }
    }

    func refresh(sender: AnyObject) {
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        //            print("refreshing")
        //            //                        sleep(2)
        //
        //
        //
        //            self.data.dataSources.removeAll()
        //
        //            for var i = 0; i < 5; i++ {
        //                //(0 - 100)
        //                let datasource = DataSource()
        //                datasource.name = "\(arc4random() % 100)"
        //                //(0 - 1)
        //                datasource.slideValue = Float(arc4random()) / Float(UINT32_MAX)
        //                self.data.dataSources.append(datasource)
        //                print(datasource.name)
        //                print(datasource.slideValue)
        //            }
        //
        //            dispatch_async(dispatch_get_main_queue()) {
        //                self.refreshControl!.endRefreshing()
        //                print("Refresh End")
        //                self.tableView.reloadData()
        //                print("Table Reloaded")
        //            }
        //        }

        //photo不为空删除数据库
        if !photos.isEmpty {
            FMDBHelper.deleteData()
        }

        Alamofire.request(.GET, "https://api.500px.com/v1/photos", parameters: ["consumer_key": "gvSt0s93UigEdo2LVVgRmnL1XPnXpLOx15skW2sN"]).responseJSON() {
            response in

            if let value = response.result.value {

                let photoInfos = (value.valueForKey("photos") as! [NSDictionary]).filter({
                    ($0["nsfw"] as! Bool) == false
                }).map {
                    PhotoInfo(id: $0["id"] as! Int, url: $0["image_url"] as! String)
                }
                self.photos = photoInfos
//                FMDBHelper.saveData(self.photos[1].url)
                for photoLists in self.photos {
//                    print(photoLists.url)
                    FMDBHelper.saveData(photoLists.url)
                }
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photos.isEmpty {
            return 1
        }
        return photos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("protoCell", forIndexPath: indexPath)
        //设置cell选中不变色
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let label = cell.viewWithTag(100) as! UILabel
        let progressView = cell.viewWithTag(101) as! UIProgressView
        let pictureView = cell.viewWithTag(102) as! UIImageView

        cell.backgroundColor = bgColor
        label.textColor = txtColor

        if photos.isEmpty {
            label.text = "test"
        } else {
            let imageURL = photos[indexPath.row].url
//            print(imageURL)
            pictureView.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named: "testPic"))
            label.text = "\(indexPath.row)"
            progressView.setProgress(Float(arc4random()) / Float(UINT32_MAX), animated: true)
        }

        return cell
    }

    //make delegate first in SB
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }

}

