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
import MapKit

class InputCell:UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
}

class MakePaymentTableViewController: UITableViewController {
    let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
    let pointer = MKPointAnnotation()
    class var viewConroller:MakePaymentTableViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "makePayment") as! MakePaymentTableViewController
    }
    enum PaymentType {
        case plus
        case minus
    }
    
    var pType:PaymentType = .minus
    
    var data:PaymentModel? = nil
    
    var tagSearchLength:Double = 0.0001
    
    //추천태그 목록
    var tagList:[String] = []
    
    //전체 태그
    var totalTags:Results<TagModel> {
        return try! Realm().objects(TagModel.self).filter("isPlus = %@",self.pType == .plus)
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
            title = "expenditure".localized
        default:
            title = "income".localized
        }
        mapView.addAnnotation(self.pointer)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false

        if let point = self.point {
            let region = MKCoordinateRegionMakeWithDistance(point, 200, 200)
            mapView.setRegion(region, animated: false)
        }

    }
    
    @objc func onTouchDone(_ sender:UIBarButtonItem) {
        guard let mylocation = Utill.navigationController?.myPointer else {
            return
        }
        let realm = try! Realm()
        if let d = data {
            realm.beginWrite()
            loadData(d)
            try! realm.commitWrite()
            navigationController?.popViewController(animated: true)
            return
        }
        
        if moneyTextField?.text?.isEmpty == true && tagTextField?.text?.isEmpty == true {
            return
        }
        
        let model = PaymentModel()
        loadData(model)
        model.locailIdentifier = Locale.current.identifier
        if let region = Locale.current.regionCode {
            model.region = region
        }
        model.latitude = mylocation.coordinate.latitude
        model.longitude = mylocation.coordinate.longitude
        model.id = "\(model.longitude) \(model.longitude) \(model.tag)"
        model.datetime = Date()
        realm.beginWrite()
        realm.add(model, update: true)
        try! realm.commitWrite()
        navigationController?.popViewController(animated: true)
    }
    
    private func loadData(_ model:PaymentModel) {
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
            let tmodel = TagModel()
            tmodel.isPlus = model.money > 0
            tmodel.tag = text
            objs.append(tmodel)
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
        moneyTextField?.text = nil
        tagTextField?.text = nil
        if let d = data {
            moneyTextField?.text = "\(abs(d.money))"
            tagTextField?.text = d.tag
        }
        for tf in [moneyTextField, tagTextField] {
            tf?.delegate = self
        }
        self.tagTextField?.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.onTouchDone(_:)))

        loadTagData()

    }
    var point:CLLocationCoordinate2D? {
        guard var point = Utill.navigationController?.myPointer.coordinate else {
            return nil
        }
        if let data = self.data {
            point = data.coordinate2D
        }
        return point
    }
    
    @objc func loadTagData() {
        guard let point = self.point else {
            return
        }
        pointer.coordinate = point
        
        DispatchQueue.global().async {
            let length = self.tagSearchLength
            let la_min = point.latitude - length
            let la_max = point.latitude + length
            let lo_min = point.longitude - length
            let lo_max = point.longitude + length
            
            var list = try! Realm().objects(PaymentModel.self).filter("latitude > %@ && latitude < %@ && longitude > %@ && longitude < %@",la_min, la_max, lo_min, lo_max)
            list = self.pType == .plus ? list.filter("money > %@", 0) : list.filter("money < %@", 0)
            
            var tags:[String] = []
            for pay in list {
                for tag in pay.tag.components(separatedBy: " ") {
                    if tags.index(of: tag) == nil {
                        if tag.isEmpty == false {
                            tags.append(tag)
                        }
                    }
                }
            }
            self.tagList = tags
            if tags.count == 0 {
                self.tagSearchLength *= 2
                if self.tagSearchLength < 0.001 {
                    self.perform(#selector(self.loadTagData))
                }
            }
            if tags.count > 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tagTextField?.becomeFirstResponder()
                }
            }
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return tagList.count
        case 2:
            return totalTags.count
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
            cell.textLabel?.text = tag
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tag", for: indexPath)
            let tag = totalTags[indexPath.row]
            cell.textLabel?.text = tag.tag
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        func appendTag(_ tag:String) {
            if let text = tagTextField?.text {
                let list = text.components(separatedBy: " ")
                if list.filter({ (t) -> Bool in
                    return t == tag
                }).count > 0 {
                    return
                }
            }
            if tagTextField?.text?.isEmpty == false {
                tagTextField?.text?.append(" ")
            }
            tagTextField?.text?.append(tag)
            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            appendTag(tagList[indexPath.row])
        case 2:
            appendTag(totalTags[indexPath.row].tag)
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return pType == .plus ? "income".localized : "expenditure".localized
        case 1:
            if tagList.count == 0 {
                return nil
            }
            return "Location info suggest tag".localized
        case 2:
            if totalTags.count == 0 {
                return nil
            }
            return "select tag".localized
        default:
            return nil            
        }
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 1:
            return mapView
        default:
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 80
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 2:
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
                    let tag = self.totalTags[indexPath.row]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.delete(tag)
                    try! realm.commitWrite()
                    if self.totalTags.count > 0 {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    else {
                        tableView.reloadData()
                    }
                }))
                ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            })
        ]
    }
}
