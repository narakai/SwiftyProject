//
//  DataModel.swift
//  PlaySwift
//
//  Created by leon on 16/1/18.
//  Copyright © 2016年 Clem. All rights reserved.
//

import Foundation

class DataModel {
    
    var dataSources = [DataSource]()
    
    init(){
        loadChecklists()
    }
    
    //load file
    func loadChecklists(){
        let path = dataFilePath();
        
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data);
                dataSources = unarchiver.decodeObjectForKey("Data") as! [DataSource];
                unarchiver.finishDecoding();
            }
        }
    }
    
    func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true);
        return paths[0];
    }
    
    func dataFilePath() -> String{
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("Data.plist");
    }
    
    //save file
    func saveChecklists(){
        let data = NSMutableData();
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data);
        archiver.encodeObject(dataSources, forKey: "Data");
        archiver.finishEncoding();
        data.writeToFile(dataFilePath(), atomically: true);
    }

}
