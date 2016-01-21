//
// Created by leon on 16/1/21.
// Copyright (c) 2016 Clem. All rights reserved.
//

import Foundation
import FMDB

class FMDBHelper {

    static func saveData(photoUrl: String) {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("playSwift.sqlite")

        let database = FMDatabase(path: fileURL.path)

        if !database.open() {
            print("Unable to open database")
            return
        }

        do {
            try database.executeUpdate("create table if not exists test8(photoUrl text)", values: nil)
            //todo 清空原数据
            try database.executeUpdate("insert into test8 (photoUrl) values (?)", values: [photoUrl])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }

        database.close()
    }

    static func loadData() -> [PhotoInfo]? {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("playSwift.sqlite")

        let database = FMDatabase(path: fileURL.path)
        var photos = [PhotoInfo]()

        if database.open() {
            do {
                let rs = try database.executeQuery("select photoUrl from test8", values: nil)

                while rs.next() {
                    let x = rs.stringForColumn("photoUrl")
                    let photoInfo = PhotoInfo(id: 1, url: x)
                    photos.append(photoInfo)
                    print("photoUrl = \(x)")
                }
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }

            database.close()
        }

        return photos
    }

    static func deleteData() {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("playSwift.sqlite")

        let database = FMDatabase(path: fileURL.path)

        if !database.open() {
            print("Unable to open database")
            return
        }

        do {
            //注意! executeUpdate用于无返回值的查询, executeQuery用于有返回值的查询
            try database.executeUpdate("drop table test8", values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }

        database.close()
    }
}
