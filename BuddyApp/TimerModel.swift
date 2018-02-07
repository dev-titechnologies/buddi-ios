//
//  TimerModel.swift
//  BuddyApp
//
//  Created by Ti Technologies on 05/02/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class TimerModel: NSObject {
    
    static let sharedTimer: TimerModel = {
        let timer = TimerModel()
        return timer
    }()
    
    var internalTimer: Timer?
    var seconds: Int?
    let GlobelTimerNotification = Notification.Name("GlobelTimerNotification")
    
    func startTimer(withInterval interval: Double){
        if internalTimer == nil {
            internalTimer?.invalidate()
        }
        internalTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(doJob), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }
    
    func stopTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }
    
    func doJob() {
        if seconds! < 1 {
            print("GLOBELTIMER STOPPED")
            internalTimer?.invalidate()
            NotificationCenter.default.post(name: GlobelTimerNotification, object: nil, userInfo: nil)
        }else{
            seconds! -= 1
            print("GLOBELTIMER RUNNING",seconds!)
        }
      }


}
