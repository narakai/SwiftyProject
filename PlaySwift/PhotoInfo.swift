//
//  PhotoInfo.swift
//  PlaySwift
//
//  Created by leon on 16/1/20.
//  Copyright © 2016年 Clem. All rights reserved.
//

import Foundation

class PhotoInfo: NSObject {
    let id: Int
    let url: String

    init(id: Int, url: String) {
        self.id = id
        self.url = url
    }

}