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

}
