//
//  NotificationClass.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 24/12/21.
//

/*
 * -- NotificationClass module --
 * Holds the NotificationClass class, for notification sending when a timer elapses and app
 * is in foreground
 *
 * Attrib: IDENTIFIER
 * Attrib: notificationTitle
 * Attrib: notificationBody
 * init(startTime: Double, for deviceType: String)
 * Method: registerForLocalNotification()
 * Method: stopNotification()
 */


import Foundation
import NotificationCenter


class NotificationClass{
    
    // Constant notification parameters
    var identifier: String!
    let notificationTitle = "Timer elapsed!"
    var notificationBody: String!
    
    
    // MARK: Class' initializer, in charge of actually creating a notification object
    init(startTime: Double, for deviceType: String) {
        // Setting up notification instance attributes
        notificationBody = "Your \(deviceType) has finished"
        identifier = String(constants.NOTIFICATION_COUNTER)
        constants.NOTIFICATION_COUNTER += 1
        
        // Making sure current device has right capabilities
        if #available(iOS 10, *){
           
            // Setting up the notification
            let content = UNMutableNotificationContent()
            content.title = notificationTitle
            content.body = notificationBody
            
            // Actually sending the notification
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: startTime, repeats: false)
            let notification = UNNotificationRequest(identifier: String(identifier), content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notification)
            
        }
    }
    
    
    // MARK: This function is in charge of asking the user for notification authorisation
    func registerForLocalNotification() {
        // Making sure current device has right capabilities
        if #available(iOS 10, *){
            // Requesring user for notification sending authorisation
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { succ, err in
                guard succ, err == nil else {
                    print("-- Error in notification setup --")
                    return
                }
            }
        } else {
            print("-- Feature not supported on current device --")
        }
    }
    
    
    // MARK: Function that removes/clears current notifications
    func stopNotification() {
        let centre = UNUserNotificationCenter.current()
        centre.removePendingNotificationRequests(withIdentifiers: [identifier])
        centre.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
