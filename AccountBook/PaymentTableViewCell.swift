//
//  PaymentTableViewCell.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 17..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import TagListView
class PaymentTableViewCell: UITableViewCell {
    @IBOutlet weak var tagListView:TagListView!
    @IBOutlet weak var timeLabel:UILabel!
    @IBOutlet weak var moneyLabel:UILabel!
    
    func loadData(_ pay:PaymentModel, timeFormat:String = "ah:mm") {
        tagListView.removeAllTags()
        tagListView.addTags(pay.tag.components(separatedBy: " "))
        if let time = pay.datetime {
            timeLabel.text = time.toString(timeFormat, locale: pay.locale)
        }
        moneyLabel.text = pay.money.toMoneyFormatString(pay.locale)
        moneyLabel.textColor = pay.money < 0 ? .red : .black
    }
    
}
