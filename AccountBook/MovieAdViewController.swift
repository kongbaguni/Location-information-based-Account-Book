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
import JHUD
import RealmSwift

class MovieAdViewController: UIViewController {
    let rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()

    var rewardList:Results<RewordModel> {
        return try! Realm().objects(RewordModel.self)
    }
    
    let loading = JHUD()
    var request:GADRequest? = nil
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewardBasedVideo.delegate = self
        loading.frame.size = view.bounds.size
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func loadVideo() {
        if let req = self.request {
            rewardBasedVideo.load(req, withAdUnitID: Const.GoogleMovieAdId)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loading.frame.size = view.bounds.size
        confirmBtn.setTitle("show AD".localized, for: .normal)
    }
    
    @IBAction func onTouchupConfirmBtn(_ sender:UIButton) {
        self.request = GADRequest()
        loadVideo()
        loading.show(at: view, hudType: .circle)
    }
    
    func makeReword(reword:GADAdReward) {
        let mylocation = Location.myPosition

        print(mylocation)
        let model = RewordModel()
        model.type = reword.type
        model.amount = reword.amount.intValue
        model.latitude = mylocation.latitude
        model.longitude = mylocation.longitude
        model.datetime = Date()

        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(model)
            try realm.commitWrite()
            self.tableView.reloadData()
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
                let reward = sender as? RewordModel {
                vc.pointer.coordinate = reward.coordinate2D
            }
        default:
            break
        }

    }
}

extension MovieAdViewController : GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        rewardBasedVideo.present(fromRootViewController: self)
        loading.hide()
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        self.makeReword(reword: reward)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
        perform(#selector(self.loadVideo), with: nil, afterDelay: 1)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        
    }
}


extension MovieAdViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reward = rewardList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reward", for: indexPath)
        cell.textLabel?.text = reward.datetime?.toString("yyyy-MM-dd")
        cell.detailTextLabel?.text = "\(reward.amount)"
        return cell
    }
}

extension MovieAdViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reward = rewardList[indexPath.row]
        performSegue(withIdentifier: "showMap", sender: reward)
    }
}
