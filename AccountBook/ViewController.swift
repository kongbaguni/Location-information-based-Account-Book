//
//  ViewController.swift
//  locationTest
//
//  Created by Seo Changyul on 2017. 10. 14..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift
import TagListView
class NavigationController: UINavigationController  {
    let locationManager = CLLocationManager()
    let myPointer = MKPointAnnotation()
    
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationManager: CLLocationManager? {
        return Utill.navigationController?.locationManager
    }
    
    var myPointer:MKPointAnnotation? {
        return Utill.navigationController?.myPointer
    }
    
    let shopPointer = MKPointAnnotation()
    
    var paymentList:Results<PaymentModel> {
        var list = try! Realm().objects(PaymentModel.self)
        if let todayStart = Date().toString("yyyy-MM-dd", locale: Locale.current).toDate("yyyy-MM-dd") {
            list = list.filter("%@ <= datetime", todayStart)
        }
        return list
    }
    
    var paymentLocaleList:[Locale] {
        var list:[Locale] = []
        for pay in paymentList {
            if list.filter({ (locale) -> Bool in
                return locale.regionCode == pay.locale.regionCode
            }).count == 0 {
                list.append(pay.locale)
            }
        }
        return list
    }
    var isSetFirstPos:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        view.addSubview(mapView)
        title = Date().toString("yyyy-MM-dd", locale: Locale.current)
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.onTouchRightButton(_:)))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        if let point = myPointer {
            mapView.addAnnotation(point)
        }
        mapView.addAnnotation(shopPointer)
        tableView.reloadData()
    }
    
    
    @objc func onTouchRightButton(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: "showTagList", sender: nil)
        
    }
    
    func findMyPos(_ cordinate:CLLocationCoordinate2D?) {
        guard let c = cordinate else {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(c, 200, 200)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showTagsPayment":
            if let vc = segue.destination as? TagsPayListTableViewController {
                vc.tag = sender as? String
                vc.tableView.reloadData()
            }
        case "makePayment":
            if let vc = segue.destination as? MakePaymentTableViewController {
                if let type = sender as? MakePaymentTableViewController.PaymentType {
                    vc.pType = type
                }
                if let data = sender as? PaymentModel {
                    vc.data = data
                    vc.pType = data.money < 0 ? .minus : .plus
                }
            }
        default:
            break
        }
        
    }
    
}

extension ViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myPointer?.coordinate = location.coordinate
            if isSetFirstPos == false {
                findMyPos(location.coordinate)
                isSetFirstPos = true
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
}

extension ViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.paymentList.count
        case 1:
            return self.paymentLocaleList.count
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pay", for: indexPath) as! PaymentTableViewCell
            let payment = self.paymentList[indexPath.row]
            cell.loadData(payment)
            cell.tagListView.delegate = self
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sum", for: indexPath)
            let locale = paymentLocaleList[indexPath.row]
            let payList = paymentList.filter("region = %@",locale.regionCode!)
            let a = payList.filter("money < 0").count
            let b = payList.filter("money > 0").count
            var title = ""
            if a > 0 {
                title.append(String(format:"expenditure: %d".localized, a))
            }
            if b < 0 {
                if title != "" {
                    title.append(", ")
                }
                title.append(String(format:"income: %d".localized, b))
            }
            cell.textLabel?.text = title
            var total = 0
            for pay in payList {
                total += pay.money
            }
            cell.detailTextLabel?.text = total.toMoneyFormatString(locale)
            cell.detailTextLabel?.textColor = total >= 0 ? .black : .red
            return cell

        case 2:
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "plus")!
            case 1:
                return tableView.dequeueReusableCell(withIdentifier: "minus")!
            default:
                break
            }
        default:
            break
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if paymentList.count == 0 {
                return nil
            }
            return "income,expenditure".localized
        case 1:
            if paymentLocaleList.count == 0 {
                return nil
            }
            return "sum".localized
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if paymentList.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 50
        case 1:
            if paymentLocaleList.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 50
        case 2:
            return 50
        default:
            break
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
}
extension ViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let payment = self.paymentList[indexPath.row]
            shopPointer.coordinate = payment.coordinate2D
            findMyPos(payment.coordinate2D)
        case 2:
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "makePayment", sender: MakePaymentTableViewController.PaymentType.plus)
            case 1:
                self.performSegue(withIdentifier: "makePayment", sender: MakePaymentTableViewController.PaymentType.minus)
            default:
                break
            }
            findMyPos(myPointer?.coordinate)
        default:
            findMyPos(myPointer?.coordinate)
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return true
        default:
            break
        }
        return false
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "delete".localized, handler: { (action, indexPath) in
                let ac = UIAlertController(title: nil, message: "Do you want to delete it?".localized, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                    let payment = self.paymentList[indexPath.row]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.delete(payment)
                    try! realm.commitWrite()
                    DispatchQueue.main.async {
                        if self.paymentList.count > 0 {
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
                let data:PaymentModel = self.paymentList[indexPath.row]
                self.performSegue(withIdentifier: "makePayment", sender: data)
            })
        ]
    }
}


extension ViewController : TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print(title)
        self.performSegue(withIdentifier: "showTagsPayment", sender: title)
    }
}
