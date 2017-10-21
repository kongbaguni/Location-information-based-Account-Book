//
//  TagListTableViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 19..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
class TagListTableViewController: UITableViewController {
 
    var tags:Results<TagModel> {
        return try! Realm().objects(TagModel.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "tag list".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tags.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let tag = tags[indexPath.row]
            let tagstr = tag.tag
            cell.textLabel?.text = tagstr
            DispatchQueue.global().async {
                let count = try! Realm().objects(PaymentModel.self).filter("tag contains[C] %@",tagstr).count
                DispatchQueue.main.async {
                    cell.detailTextLabel?.text = "\(count)"
                }
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
            cell.textLabel?.text = "total".localized
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: "showTagsPayment", sender: tags[indexPath.row])
        case 1:
            self.performSegue(withIdentifier: "showTagsPayment", sender: nil)
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showTagsPayment":
            if let vc = segue.destination as? TagsPayListTableViewController {
                if let tag = sender as? TagModel {
                    vc.tag = tag.tag
                }
            }
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            let pays:Results<PaymentModel> = try! Realm().objects(PaymentModel.self).filter("tag contains[C] %@",self.tags[indexPath.row].tag)
            if pays.count > 0 {
                return false
            }
            return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "delete".localized, handler: { (action, indexPath) in
                let ac = UIAlertController(title: nil, message: "Do you want to delete it?".localized, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                    let tag = self.tags[indexPath.row]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.delete(tag)
                    try! realm.commitWrite()
                    DispatchQueue.main.async {
                        if self.tags.count > 0 {
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
            })
        ]

    }

}
