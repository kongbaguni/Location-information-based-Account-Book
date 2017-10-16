//
//  TagModel.swift
//  locationTest
//
//  Created by Seo Changyul on 2017. 10. 15..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import RealmSwift
class TagModel: Object {
    @objc dynamic var tag:String = ""
    //수입인가? false 면 지출
    @objc dynamic var isPlus:Bool = false
    override static func primaryKey() -> String? {
        return "tag"
    }

}
