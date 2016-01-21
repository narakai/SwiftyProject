//
//  DataSource.swift
//  PlaySwift
//
//  Created by leon on 16/1/18.
//  Copyright © 2016年 Clem. All rights reserved.
//

import Foundation

class DataSource: NSObject, NSCoding {
    var name = ""
    var slideValue = Float(0.5)

    init(name: String, slideValue: Float) {
        self.name = name
        self.slideValue = slideValue
        super.init()
    }

    override init() {
        super.init()
    }

    //add plist support
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        slideValue = aDecoder.decodeObjectForKey("slideValue") as! Float
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(slideValue, forKey: "slideValue")
    }

    }
