//
//  TimerClass.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 24/12/21.
//

/*
 * -- TimerClass module --
 * Holds the TimerClass class, which deals with all timer operations
 *
 * Singleton: timerKey
 * Attrib: timer
 * Attrib: startTime
 * Attrib: elapsedTime
 * Attrib: duration
 * Attrib: hasElapsed
 * Attrib: delegate
 * Attrib: elapsedNotification
 * Attrib: state
 * init(time: Double, includeNotification: Bool=true)
 * Method: timerAction()
 */


import Foundation
import UIKit
import UserNotifications


class TimerClass {
    // String key for timer referencing
    static let timerKey = "tKEY"
    
    // Main timer object for time keeping
    var timer: Timer!
    
    // Timer parameters
    var startTime: Date!
    var elapsedTime: TimeInterval = 0
    var duration: TimeInterval!
    var hasElapsed = false
    
    // Protocol interaction attribute and other general porpuse attributes
    var delegate: TimerProtocol?
    var elapsedNotification: NotificationClass!
    let state = UIApplication.State.background
    
    
    // MARK: Constructor for timer object initialization
    init(time: Double, deviceType: String, includeNotification: Bool=true) {
        // Starting timer at current timer
        startTime = Date()
        UserDefaults.standard.set(startTime, forKey: "tKEY")
        duration = time
        
        // Starting timer
        timer = Timer.scheduledTimer(timeInterval: 1/constants.WARP_SPEED_FACTOR, target: self,
                                     selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        // Preparing elapsed timer notification
        guard includeNotification else { return }
        elapsedNotification = NotificationClass(startTime: time/constants.WARP_SPEED_FACTOR, for: deviceType)
        
        //NotificationClass.shared.createNotification(startTime: time/constants.WARP_SPEED_FACTOR)
        
        timerAction()
    }
    
    
    // MARK: function called at every timer tick, which, in its turn, will call an appropriate protocol function
    @objc dynamic func timerAction() {
        // Verifying timer has been setup properly
        guard let startTime = startTime else {
            return
        }
        
        // Updating elapsed time
        elapsedTime = -startTime.timeIntervalSinceNow * constants.WARP_SPEED_FACTOR
        
        // Calculating time remaining
        let secondsRemaining = (duration - elapsedTime).rounded()
        
        // Checking whether timer has elapsed completly or not
        if secondsRemaining <= 0 {
            // Resetting timer
            timer?.invalidate()
            timer = nil
            
            // Calling appropriate protocol function
            delegate?.timerHasFinished(sender: self)
        } else {
            // Calling appropriate protocol function
            delegate?.timeRemainingOnTimer(sender: self, timeRemaining: secondsRemaining)
        }
    }
}
