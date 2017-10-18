//
//  TagsPayListTableViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 18..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import TagListView

class TagsPayListTableViewController: UITableViewController {
    var tag:String? = nil {
        didSet {
            self.title = tag
        }
    }
    
    var payList:Results<PaymentModel>? {
        if let tag = self.tag {
            return try! Realm().objects(PaymentModel.self).filter("tag contains[C] %@", tag)
        }
        return nil
    }
    
    var paymentLocaleList:[Locale] {
        guard let payList  = self.payList else {
            return []
        }
        var list:[Locale] = []
        for pay in payList {
            if list.filter({ (locale) -> Bool in
                return locale.regionCode == pay.locale.regionCode
            }).count == 0 {
                list.append(pay.locale)
            }
        }
        return list
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "editPayment":
            if let vc = segue.destination as? MakePaymentTableViewController {
                if let data = sender as? PaymentModel {
                    vc.data = data
                    vc.pType = data.money < 0 ? .minus : .plus
                }
            }
        default:
            break
        }

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let list = payList {
                return list.count
            }
            return 0
        case 1:
            return paymentLocaleList.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pay", for: indexPath) as! PaymentTableViewCell
            let pay = payList![indexPath.row]
            cell.loadData(pay, timeFormat: "yyyy-MM-dd ah:mm")
            cell.tagListView.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let locale = paymentLocaleList[indexPath.row]
            let payList = self.payList!.filter("region = %@",locale.regionCode!)
            let a = payList.filter("money < 0").count
            let b = payList.filter("money > 0").count
            cell.textLabel?.text = "지출 \(a) 건, 수입 \(b) 건"
            var total = 0
            for pay in payList {
                total += pay.money
            }
            cell.detailTextLabel?.text = total.toMoneyFormatString(locale)
            cell.detailTextLabel?.textColor = total >= 0 ? .black : .red
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let pays = self.payList else {
            return nil
        }
        return [
            UITableViewRowAction(style: .destructive, title: "delete".localized, handler: { (action, indexPath) in
                let ac = UIAlertController(title: nil, message: "Do you want to delete it?".localized, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                    let payment = pays[indexPath.row]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.delete(payment)
                    try! realm.commitWrite()
                    DispatchQueue.main.async {
                        if pays.count > 0 {
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                        }
                        else {
                            tableView.reloadData()
                        }
                    }
                }))
                ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }),
            UITableViewRowAction(style: .normal, title: "edit".localized, handler: { (action, indexPath) in
                let data:PaymentModel = pays[indexPath.row]
                self.performSegue(withIdentifier: "editPayment", sender: data)
            })
        ]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}

extension TagsPayListTableViewController : TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.tag = title
        self.title = title
        tableView.reloadData()
    }
}
