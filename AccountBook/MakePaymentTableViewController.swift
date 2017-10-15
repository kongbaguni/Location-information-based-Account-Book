//
//  MakePaymentTableViewController.swift
//  locationTest
//
//  Created by Seo Changyul on 2017. 10. 15..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
class InputCell:UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
}

class MakePaymentTableViewController: UITableViewController {
    enum PaymentType {
        case plus
        case minus
    }
    var pType:PaymentType = .minus
    var data:PaymentModel? = nil
    
    var tagList:Results<TagModel> {
        return try! Realm().objects(TagModel.self)
    }
    
    var moneyTextField:UITextField? {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell
        return cell?.textField
    }
    var tagTextField:UITextField? {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputCell
        return cell?.textField

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch pType {
        case .minus:
            title = "지출내역 작성"
        default:
            title = "수입내역 작성"
        }
    }
    
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            guard let mylocation = Utill.navigationController?.myPointer else {
                return
            }
            let realm = try! Realm()
            if let d = data {
                realm.beginWrite()
                loadData(d)
                try! realm.commitWrite()
                return
            }
            
            if moneyTextField?.text?.isEmpty == true && tagTextField?.text?.isEmpty == true {
                return
            }
            
            let model = PaymentModel()
            loadData(model)
            model.locailIdentifier = Locale.current.identifier
            model.latitude = mylocation.coordinate.latitude
            model.longitude = mylocation.coordinate.longitude
            model.id = "\(model.longitude) \(model.longitude) \(model.tag)"
            realm.beginWrite()
            realm.add(model, update: true)
            try! realm.commitWrite()
        }
    }
    
    private func loadData(_ model:PaymentModel) {
        model.datetime = Date()
        if let text = moneyTextField?.text {
            model.money = (text as NSString).integerValue
            if pType == .minus {
                model.money *= -1
            }
        }
        if let text = tagTextField?.text {
            model.tag = text
        }
        var objs:[Object] = []
        for tag in  model.tag.components(separatedBy: " ") {
            let text = tag.replacingOccurrences(of: " ", with: "")
            if text.isEmpty {
                continue
            }
            let model = TagModel()
            model.tag = text
            objs.append(model)
        }
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            realm.add(objs, update: true)
        }
        else {
            realm.beginWrite()
            realm.add(objs, update: true)
            try! realm.commitWrite()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tagTextField?.becomeFirstResponder()
        }
        if let d = data {
            moneyTextField?.text = "\(abs(d.money))"
            tagTextField?.text = d.tag
        }
        for tf in [moneyTextField, tagTextField] {
            tf?.delegate = self
        }
    }
}

extension MakePaymentTableViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagTextField {
            moneyTextField?.becomeFirstResponder()
        }
        return true
    }
}


extension MakePaymentTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return tagList.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "tagInput", for: indexPath)
            default:
                return tableView.dequeueReusableCell(withIdentifier: "moneyInput", for: indexPath)
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tag", for: indexPath)
            let tag = tagList[indexPath.row]
            cell.textLabel?.text = tag.tag
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            break
        case 1:
            let tag = tagList[indexPath.row]
            if let text = tagTextField?.text {
                let list = text.components(separatedBy: " ")
                if list.filter({ (t) -> Bool in
                    return t == tag.tag
                }).count > 0 {
                    return
                }
            }
            if tagTextField?.text?.isEmpty == false {
                tagTextField?.text?.append(" ")
            }
            tagTextField?.text?.append(tag.tag)
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return pType == .plus ? "수입" : "지출"
        case 1:
            return "태그 선택"
        default:
            return nil            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
