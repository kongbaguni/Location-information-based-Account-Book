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

class MovieAdViewController: UIViewController {
    let rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        rewardBasedVideo.delegate = self
        loadVideo()
    }
    
    @objc func loadVideo() {
        rewardBasedVideo.load(GADRequest(), withAdUnitID: Const.GoogleMovieAdId)
    }
    
}

extension MovieAdViewController : GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        rewardBasedVideo.present(fromRootViewController: self)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        dismiss(animated: true, completion: nil)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
        perform(#selector(self.loadVideo), with: nil, afterDelay: 1)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        dismiss(animated: true, completion: nil)
    }
}
