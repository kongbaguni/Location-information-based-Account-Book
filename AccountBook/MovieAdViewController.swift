//
//  MovieAdViewController.swift
//  AccountBook
//
//  Created by Seo Changyul on 2017. 11. 13..
//  Copyright © 2017년 Seo Changyul. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import PKHUD
import RealmSwift

class MovieAdViewController: UITableViewController {
    let rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()

    var rewardList:[Results<RewardModel>] {
        let total = try! Realm().objects(RewardModel.self)
        
        guard let firstDate = total.first?.datetime else {
            return []
        }
        
        let dates:[Date] = Utill.getDateList(firstDate)
        var list:[Results<RewardModel>] = []
        for dayStart in dates {
            let dayEnd = Date(timeIntervalSince1970: dayStart.timeIntervalSince1970 + 60 * 60 * 24)
            list.append(total.filter("%@ <= datetime && %@ > datetime", dayStart, dayEnd))
        }
        return list
    }
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewardBasedVideo.delegate = self
        confirmBtn.setTitle("show AD".localized, for: .normal)
        
        bannerView.adUnitID = Const.GoogleBannerAdId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        title = "show AD".localized
        
    }
    
    
    @IBAction func onTouchupConfirmBtn(_ sender:UIButton) {
        HUD.show(.progress)
        rewardBasedVideo.load(GADRequest(), withAdUnitID: Const.GoogleMovieAdId)
    }
    
    var myPoint:Int = 0
    
    func makeReword(reword:GADAdReward) {
        
        myPoint = Int(Date().timeIntervalSince1970)%1000+1 * reword.amount.intValue
        let mylocation = Location.myPosition
        
        print(mylocation)
        let model = RewardModel()
        model.type = reword.type
        model.amount = myPoint
        model.latitude = mylocation.latitude
        model.longitude = mylocation.longitude
        model.datetime = Date()
        
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(model)
            try realm.commitWrite()
        }
        catch {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showMap":
            if let vc = segue.destination as? MapViewController ,
                let reward = sender as? RewardModel {
                vc.pointer.coordinate = reward.coordinate2D
            }
        default:
            break
        }
    }
    
}

//MARK:-
//MARK:GADRewardBasedVideoAdDelegate
extension MovieAdViewController : GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        myPoint = 0
        HUD.flash(.success, onView: nil, delay: 1) { (sucess) in
            self.rewardBasedVideo.present(fromRootViewController: self)
            PKHUD.sharedHUD.hide()
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        makeReword(reword: reward)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        rewardBasedVideo.load(GADRequest(), withAdUnitID: Const.GoogleMovieAdId)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if myPoint > 0 {
            let vc = UIAlertController(title: "\(myPoint) point!", message: nil, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel, handler: { (action) in
                self.tableView.reloadData()
            }))
            self.present(vc, animated: true, completion: nil)
        }

    }
}

//MARK:-
//MARK:GADBannerViewDelegate
extension MovieAdViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
        
    }
}

//MARK:-
//MARK:TableViewDataSource
extension MovieAdViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.rewardList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardList[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reward = rewardList[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reward", for: indexPath)
        cell.textLabel?.text = reward.datetime?.toString("a h:m:s")
        cell.detailTextLabel?.text = "\(reward.amount) point"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return rewardList[section].first?.datetime?.toString("yyyy-MM-dd")
    }
}

//MARK:-
//MARK:TableViewDelegate
extension MovieAdViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reward = rewardList[indexPath.section][indexPath.row]
        performSegue(withIdentifier: "showMap", sender: reward)
    }
}
