//
//  TimerProtocol.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 24/12/21.
//

/*
 * -- TimerProtocol protocol module --
 * Holds TimerProtocol protocol, for timer event handling
 *
 * Func: timeRemainingOnTimer(_ timer: TimerClass, timeRemaining: TimeInterval)
 * Func: timerHasFinished(_ timer: TimerClass)
 */

import Foundation


protocol TimerProtocol {
    
    // This function will be called, in all implementations, at every timer tick (normally, every second)
    func timeRemainingOnTimer(sender caller: TimerClass, timeRemaining: TimeInterval)
    
    // This function will be called, in all implementations, at the end of a timer's cycle (= time elapsed)
    func timerHasFinished(sender timer: TimerClass)
}
