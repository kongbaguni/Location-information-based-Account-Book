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
    
    var paymentList:Results<PaymentModel> {
        return try! Realm().objects(PaymentModel.self)
    }
    
    var paymentLocaleList:[Locale] {
        var list:[Locale] = []
        for pay in paymentList {
            if let _ = list.index(of: pay.locale) {
                
            } else {
                list.append(pay.locale)
            }
        }
        return list
    }
    
    let buyPointer = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        view.addSubview(mapView)
        title = Date().toString("YYYY-mm-dd", locale: Locale.current)
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchRightButton(_:)))
        
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
        mapView.addAnnotation(buyPointer)
        tableView.reloadData()
    }
    
    @objc func onTouchRightButton(_ sender:UIBarButtonItem) {
        
    }
    
    func findMyPos(_ cordinate:CLLocationCoordinate2D?) {
        guard let c = cordinate else {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(c, 500, 500)
        mapView.setRegion(region, animated: true)
    }
    
}

extension ViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = tableView.indexPathForSelectedRow {
            return
        }
        if let location = locations.first {
            myPointer?.coordinate = location.coordinate
            myPointer?.title = "my position"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
        case 0:
            let payment = self.paymentList[indexPath.row]
            cell.textLabel?.numberOfLines = 2
            let attText = NSMutableAttributedString()
            attText.append(NSAttributedString(string: payment.tag, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 13)]))
            attText.append(NSAttributedString(string: "\n"))
            attText.append(NSAttributedString(
                string: payment.datetime!.toString("ah:mm", locale: payment.locale),
                attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 8) ]))
            cell.textLabel?.attributedText = attText
            
            
            cell.detailTextLabel?.text = payment.money.toMoneyFormatString(payment.locale)
            cell.detailTextLabel?.textColor = payment.money > 0 ? .black : .red
        case 1:
            let locale = paymentLocaleList[indexPath.row]
            let payList = paymentList.filter("locailIdentifier = %@",locale.identifier)
            cell.textLabel?.text = "\(payList.count) 건"
            var total = 0
            for pay in payList {
                total += pay.money
            }
            cell.detailTextLabel?.text = total.toMoneyFormatString(locale)
            cell.detailTextLabel?.textColor = total > 0 ? .black : .red

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
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if paymentList.count == 0 {
                return nil
            }
            return "지출"
        case 1:
            if paymentLocaleList.count == 0 {
                return nil
            }
            return "합계"
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
        return CGFloat.leastNormalMagnitude
    }
}
extension ViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if let sIndex = tableView.indexPathForSelectedRow {
        //            if sIndex == indexPath {
        //                tableView.deselectRow(at: indexPath, animated: true)
        //                findMyPos(myPointer?.coordinate)
        //            }
        //        }
        switch indexPath.section {
        case 0:
            let payment = self.paymentList[indexPath.row]
            buyPointer.coordinate = payment.coordinate2D
            buyPointer.title = payment.money.toMoneyFormatString(payment.locale)
            findMyPos(buyPointer.coordinate)
        case 2:
            switch indexPath.row {
            case 0:
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "makePayment") as! MakePaymentTableViewController
                vc.pType = .plus
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                self.navigationController?.performSegue(withIdentifier: "makePayment", sender: nil)
            default:
                break
            }
            tableView.deselectRow(at: indexPath, animated: true)
            findMyPos(myPointer?.coordinate)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            findMyPos(myPointer?.coordinate)
            break
        }
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
            UITableViewRowAction(style: .destructive, title: "삭제", handler: { (action, indexPath) in
                let ac = UIAlertController(title: nil, message: "삭제할까요?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
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
                ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }),
            UITableViewRowAction(style: .normal, title: "수정", handler: { (action, indexPath) in
                let data:PaymentModel = self.paymentList[indexPath.row]
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "makePayment") as! MakePaymentTableViewController
                vc.data = data
                vc.pType = data.money < 0 ? .minus : .plus
                self.navigationController?.pushViewController(vc, animated: true)
            })
        ]
    }
}
