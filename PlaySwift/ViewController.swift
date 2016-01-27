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
import Async

class ViewController: UITableViewController {
//    var data = DataModel()
    var photos = [PhotoInfo]()
    private var bgColor = UIColor()
    private var txtColor = UIColor()
    private var barTintColor = UIColor(red: 0, green: 151 / 255, blue: 122 / 255, alpha: 1)
    private var emptyDic = [String: UIImageColors]()

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
//                randomIndex = Int(arc4random_uniform(UInt32(photos.count)))
//                print("random index is \(randomIndex)")
                tableView.reloadData()
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

//        emptyDic.removeAll()

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

        if photos.isEmpty {
            label.text = "Pull to refresh"
        } else {
            let imageURL = photos[indexPath.row].url
//            print(imageURL)
//            pictureView.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named: "testPic"))
            pictureView.sd_setImageWithURL(NSURL(string: imageURL)) {
                (UIImage img, NSError err, SDImageCacheType cacheType, NSURL imgUrl) -> Void in
                if img != nil {
                    if let tempColors = self.emptyDic["\(imgUrl)"] {
                        self.bgColor = tempColors.backgroundColor
                        self.txtColor = tempColors.primaryColor
                        cell.backgroundColor = self.bgColor
                        label.textColor = self.txtColor
                        print("row color cached in \(indexPath.row) is \(tempColors.backgroundColor)")
                    } else {
                        self.getColorAsynchronously(img, withCompletion: {
                            colors in
                            self.emptyDic["\(imgUrl)"] = colors
                            self.bgColor = colors.backgroundColor
                            self.txtColor = colors.primaryColor
                            print("row color in \(indexPath.row) is \(colors.backgroundColor)")
                            cell.backgroundColor = self.bgColor
                            label.textColor = self.txtColor
                        })
                    }
                } else {
                    print("error \(indexPath.row)")
                }
//                        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
//                        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//                            // do some task
//
//                            self.emptyDic[self.photos[indexPath.row].url] = colors
//                            self.bgColor = colors.backgroundColor
//                            self.txtColor = colors.primaryColor
//                            print(colors.backgroundColor)
//                            dispatch_async(dispatch_get_main_queue()) {
//                                // update some UI
//                                cell.backgroundColor = self.bgColor
//                                label.textColor = self.txtColor
//                            }
//                        }
//                    }
//                }
            }
            label.text = "\(indexPath.row)"
            progressView.setProgress(Float(arc4random()) / Float(UINT32_MAX), animated: true)


        }

        self.navigationController?.navigationBar.barTintColor = barTintColor
//        self.navigationController?.navigationBar.translucent = false;
        return cell
    }

    //make delegate first in SB
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }

    //ensure the completion handler is always called on the main queue
    func getColorAsynchronously(tempImage: UIImage, withCompletion completionHandler: (UIImageColors) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let colors = tempImage.getColors(CGSize(width: 50, height: 50))
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(colors)
            }
        }
    }
}

