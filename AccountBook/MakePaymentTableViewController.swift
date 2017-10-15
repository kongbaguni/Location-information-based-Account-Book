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

class MakePaymentTableViewController: UITableViewController {
    enum PaymentType {
        case plus
        case minus
    }
    var pType:PaymentType = .minus
    var data:PaymentModel? = nil
    @IBOutlet weak var moneyTextField:UITextField!
    @IBOutlet weak var tagTextField:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        switch pType {
        case .minus:
            title = "지출내역 작성"
        default:
            title = "수입내역 작성"
        }
        if let d = data {
            moneyTextField.text = "\(abs(d.money))"
            tagTextField.text = d.tag
        }
        for tf in [moneyTextField, tagTextField] {
            tf?.delegate = self
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
            
            if moneyTextField.text?.isEmpty == true && tagTextField.text?.isEmpty == true {
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
        if let text = moneyTextField.text {
            model.money = (text as NSString).integerValue
            if pType == .minus {
                model.money *= -1
            }
        }
        if let text = tagTextField.text {
            model.tag = text
        }
        var objs:[Object] = []
        for tag in  model.tag.components(separatedBy: " ") {
            let model = TagModel()
            model.tag = tag
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
        tagTextField.becomeFirstResponder()
    }
}

extension MakePaymentTableViewController : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tagTextField:
            moneyTextField.becomeFirstResponder()
        default:
            break
        }
        return true
    }
}
