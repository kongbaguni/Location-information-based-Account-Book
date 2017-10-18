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
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showTagsPayment", sender: tags[indexPath.row])
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
