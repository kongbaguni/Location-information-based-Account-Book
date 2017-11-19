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
import FSCalendar

class NavigationController: UINavigationController  {
    let locationManager = CLLocationManager()
    
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var _mapview:MKMapView? = nil
    var mapView: MKMapView? {
        if let view = _mapview {
            return view
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CalendarTableViewCell {
            self._mapview = cell.mapView
            return cell.mapView
        }
        return nil
    }
    
    private var _calendar:FSCalendar? = nil
    var calendarView: FSCalendar? {
        if let view = _calendar {
            return view
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CalendarTableViewCell {
            _calendar = cell.calendar
            _calendar?.delegate = self
            _calendar?.dataSource = self
            return cell.calendar
        }
        return nil
    }
    var selectedDate:Date? = nil
    var locationManager: CLLocationManager? {
        return Utill.navigationController?.locationManager
    }
    
    
    let shopPointer = MKPointAnnotation()
    
    var paymentList:Results<PaymentModel> {
        var list = try! Realm().objects(PaymentModel.self)
        if let date = selectedDate {
            let end = Date(timeIntervalSince1970: date.timeIntervalSince1970 + 60*60*24)
            list = list.filter("%@ <= datetime && %@ > datetime", date, end)
        }
        else {
            list = list.filter("%@ <= datetime", Utill.getDayStartDt())
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//        title = Date().toString("yyyy-MM-dd", locale: Locale.current)
//        if let date = selectedDate {
//            title = date.toString("yyyy-MM-dd", locale: Locale.current)
//        }
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.onTouchRightButton(_:)))
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        calendarView?.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        mapView?.addAnnotation(shopPointer)
    }
    
    
    @objc func onTouchRightButton(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: "showMenu", sender: nil)
        
    }
        
    func findMyPos(_ cordinate:CLLocationCoordinate2D?) {
        guard let c = cordinate else {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(c, 200, 200)
        mapView?.setRegion(region, animated: true)
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
                vc.isUseDateFilter = false
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
        case "showMap":
            if let vc = segue.destination as? MapViewController,
                let pay = sender as? PaymentModel {
                vc.pointer.coordinate = pay.coordinate2D
            }
        default:
            break
        }
        
    }
    
}
//MARK:-
//MARK:CLLocationManagerDelegate
extension ViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            Location.myPosition = location.coordinate
            if mapView != nil {
                findMyPos(location.coordinate)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
}

//MARK:-
//MARK:UITableViewDataSource
extension ViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.paymentList.count
        case 2:
            return self.paymentLocaleList.count
        case 3:
            if let date = self.selectedDate {
                if date.toString("yyyy-MM-dd") != Date().toString("yyyy-MM-dd")
                {
                    return 0
                }
            }
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "calendar", for: indexPath)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pay", for: indexPath) as! PaymentTableViewCell
            let payment = self.paymentList[indexPath.row]
            cell.loadData(payment)
            cell.tagListView.delegate = self
            return cell
            
        case 2:
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
            
            let total:Int = payList.sum(ofProperty: "money")
            
            cell.detailTextLabel?.text = total.toMoneyFormatString(locale)
            cell.detailTextLabel?.textColor = total >= 0 ? .black : .red
            return cell

        case 3:
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
            return 300
        case 1:
            return 80
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            if paymentList.count == 0 {
                return nil
            }
            return "income,expenditure".localized
        case 2:
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
        case 1:
            if paymentList.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 50
        case 2:
            if paymentLocaleList.count == 0 {
                return CGFloat.leastNormalMagnitude
            }
            return 50
        case 3:
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

//MARK:UITableViewDelegate
extension ViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            findMyPos(Location.myPosition)
        case 1:
            let payment = self.paymentList[indexPath.row]
            self.performSegue(withIdentifier: "showMap", sender: payment)
        case 3:
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "makePayment", sender: MakePaymentTableViewController.PaymentType.plus)
            case 1:
                self.performSegue(withIdentifier: "makePayment", sender: MakePaymentTableViewController.PaymentType.minus)
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1:
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

//MARK:-
//MARK:TagListViewDelegate
extension ViewController : TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print(title)
        self.performSegue(withIdentifier: "showTagsPayment", sender: title)
    }
}
//MARK:-
//MARK:FSCalendarDataSource
extension ViewController : FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let d1 = Utill.getDayStartDt(date)
        let d2 = Date(timeIntervalSince1970: d1.timeIntervalSince1970 + (60*60*24))
        let count = try! Realm().objects(PaymentModel.self).filter("%@ <= datetime && %@ > datetime", d1, d2).count
        return count
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame.size = bounds.size
        mapView?.frame.origin.y = bounds.height
    }
}
//MARK:FSCalendarDelegate
extension ViewController : FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        self.tableView.reloadData()
    }

}
