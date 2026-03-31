//
//  AppDelegate.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 25/11/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setting up required constants
        let screenSize: CGRect = UIScreen.main.bounds
        
        // General display constants
        constants.SCREEN_WIDTH = screenSize.width
        constants.SCREEN_HEIGHT = screenSize.height
        
        constants.TOP_MARGIN = constants.SCREEN_HEIGHT / 10
        constants.MARGIN = constants.SCREEN_WIDTH / 32
        
        // Setting up the parameter for the session selection page
        constants.SEL_BUTTONS_SIZE = constants.SCREEN_WIDTH * 0.25
        constants.SEL_BUTTONS_LAT_OFFSET_S3 = constants.SEL_BUTTONS_SIZE * 1.25
        constants.SEL_BUTTONS_LAT_OFFSET_S2 = constants.SEL_BUTTONS_SIZE / 2.0 + constants.MARGIN
        constants.SEL_BUTTONS_VER_OFFSET_L1 = constants.SCREEN_HEIGHT / 3.5
        constants.SEL_BUTTONS_VER_OFFSET_L2 = constants.SEL_BUTTONS_VER_OFFSET_L1 + constants.SEL_BUTTONS_SIZE + constants.MARGIN
        
        // Setting up BubbleTimer parameters
        constants.BUBBLE_STARTING_SIZE = constants.SCREEN_WIDTH * constants.BUBBLE_SCREEN_RATIO_START
        constants.BUBBLE_ENDING_SIZE = constants.SCREEN_WIDTH * constants.BUBBLE_SCREEN_RATIO_END
        constants.BUBBLE_STARTING_Y = constants.SCREEN_HEIGHT + constants.BUBBLE_STARTING_SIZE
        
        constants.LABEL_FONT_STARTING_SIZE = constants.BUBBLE_STARTING_SIZE / constants.FONT_SIZE_RATIO
        
        // This part is required to compute the aspect ratio of the bubble UIImage
        let bubbleImage = UIImage(named: "Bubble")
        constants.BUBBLE_ASPECT_RATIO = bubbleImage!.size.height / bubbleImage!.size.width
        
        // Asking for notification permission
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { granted, err in print("Permission granted!") }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask(){
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.endBackgroundUpdateTask()
    }
}

