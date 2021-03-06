//
//  MenuTableViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 10. 24..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MenuTableViewController: UITableViewController {
    @IBOutlet weak var tagListCell: UITableViewCell!
    @IBOutlet weak var dateRangeOnOffCell: UITableViewCell!
    
    @IBOutlet weak var setting_daySwitch:UISwitch!
    @IBOutlet weak var setting_startDayTF:UITextField!
    @IBOutlet weak var setting_endDayTF:UITextField!
    
    @IBOutlet weak var showADCell: UITableViewCell!
    @IBOutlet weak var endDayCell: UITableViewCell!
    @IBOutlet weak var startDayCell: UITableViewCell!
    @IBAction func onChangeSwitch(_ sender:UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDayFilterEnable")
        for tf in [setting_endDayTF, setting_startDayTF] {
            tf?.isEnabled = sender.isOn
        }
        for cell in [startDayCell, endDayCell] {
            cell?.alpha = sender.isOn ? 1 : 0.5
        }
    }
    
    let pickerStart = UINib(nibName: "DateInput", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIDatePicker
    let pickerEnd = UINib(nibName: "DateInput", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIDatePicker

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting_startDayTF.text = Utill.startDay.toString("yyyy-MM-dd")
        setting_endDayTF.text = Utill.endDay.toString("yyyy-MM-dd")
        setting_startDayTF.inputView = pickerStart
        setting_endDayTF.inputView = pickerEnd
        pickerStart?.date = Utill.startDay
        pickerEnd?.date = Utill.endDay

        for picker in [pickerStart, pickerEnd] {
            picker?.addTarget(self, action: #selector(self.onChangeDatePicker(_:)), for: .valueChanged)
        }
        for tf in [setting_startDayTF, setting_endDayTF] {
            tf?.inputAccessoryView = UIToolbar().toolbarPiker(mySelect: #selector(self.onTouchDone))
        }
        DispatchQueue.main.async {
            self.setting_daySwitch.isOn = Utill.isDayFilterEnable
            for tf in [self.setting_endDayTF, self.setting_startDayTF] {
                tf?.isEnabled = self.setting_daySwitch.isOn
            }
            for cell in [self.startDayCell, self.endDayCell] {
                let alpha:CGFloat = self.setting_daySwitch.isOn ? 1 : 0.5
                cell?.alpha = alpha
            }
        }
        
        tagListCell.textLabel?.text = "tag list".localized
        dateRangeOnOffCell.textLabel?.text = "Set date range".localized
        startDayCell.textLabel?.text = "start date".localized
        endDayCell.textLabel?.text = "end date".localized
        showADCell.textLabel?.text = "show AD".localized
        
    }
    
    
    @objc func onTouchDone() {
        for tf in [setting_startDayTF, setting_endDayTF] {
            tf?.resignFirstResponder()
        }
    }
    
    @objc func onChangeDatePicker(_ picker:UIDatePicker) {
        guard let s = self.pickerStart, let e = self.pickerEnd else {
            return
        }
        switch picker {
        case s:
            setting_startDayTF.text = picker.date.toString("yyyy-MM-dd")
            UserDefaults.standard.set(picker.date.toString(), forKey: "startDate")
        case e:
            setting_endDayTF.text = picker.date.toString("yyyy-MM-dd")
            UserDefaults.standard.set(picker.date.toString(), forKey: "endDate")
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "statistics".localized
        case 1:
            return "setting".localized
        case 2:
            return "ad title".localized
        default:
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let total:Int = try! Realm().objects(RewardModel.self).sum(ofProperty: "amount")
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        if let number = formater.string(from:NSNumber(value: total)) {
            showADCell.detailTextLabel?.text = "\(number) Point"
        }
    }
}
