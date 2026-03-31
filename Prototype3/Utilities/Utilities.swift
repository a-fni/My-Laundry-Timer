//
//  Utilities.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 25/11/21.
//

/*
 * -- Various functions and constants module --
 * The purpose of this module is to host some general purpose functions and all app constants / parameters
 *
 * Func: formatTimeText(givenMinutes mins: Int=0, givenSeconds secs: Int=0) -> String 
 * Func: getVerticalAllignment(amount n: Int) -> CGFloat
 * Struct: constants_t
 */


import Foundation
import UIKit


// MARK: Function that properly formats time left (as MINUTES:SECONDS)
func formatTimeText(givenMinutes mins: Int=0, givenSeconds secs: Int=0) -> String {
    let minutes = String(mins + secs / 60)
    var seconds = String(secs % 60)
    
    seconds = seconds.count == 1 && minutes != "0" ? "0" + seconds : seconds
    
    return minutes == "0" ? seconds : "\(minutes):\(seconds)"
}


// MARK: This function will return, given a number of bubbles currenty on screen, where a new one has to be placed (vertically)
func getVerticalAllignment(amount n: Int) -> CGFloat {
    // Each bubble has a given height, and there are n bubbles which stack vertically left and right.
    // We'll use constants.MARGIN to separate each bubble, and we'll start placing bubbles from constants.TOP_MARGIN
    if n == 0 {
        return constants.BUBBLE_STARTING_SIZE / 2 + constants.TOP_MARGIN
    } else if n == 1 {
        return constants.BUBBLE_STARTING_SIZE / 2.0 + constants.TOP_MARGIN + 2.0 * constants.MARGIN
    } else if n < 0 {
        fatalError("--- getVerticalAllignment: invalid amount of bubbles passed ---")
    }
    
    // Recursively calling function to get Y coordinate of "above" bubble
    return getVerticalAllignment(amount: n-2) + (constants.BUBBLE_STARTING_SIZE * constants.BUBBLE_ASPECT_RATIO) + constants.MARGIN
}


// This arrays withhold all the times for the different programmes and modes of washer and drier
let washerProgrammesDatabase = [
    [40, 40, 40, 36, 34, 34],
    [40, 40, 40, 36, 34, 34],
    [40, 40, 40, 36, 34, 34]]
let drierProgrammesDatabase = [50, 50, 50, 50, 33]


// Various constants and app parameters
struct constants_t {
    var NOTIFICATION_COUNTER = 0                    // Variable used to assign unique identifiers to notification
    
    var TOP_MARGIN: CGFloat!                        // Margin from vertical edge from where a bubble spawns
    var MARGIN: CGFloat!                            // Margin from lateral edges at which a bubble spawns
    var SCREEN_WIDTH: CGFloat!                      // Device screen width
    var SCREEN_HEIGHT: CGFloat!                     // Device screen height

    let DROP_ICON_PRESSED_ALPHA: CGFloat = 0.5      // When drop icon is held, it also fades sligthly
    var DROP_ICON_RESIZE_CONSTANT: CGFloat = 20.0   // Defines how much the drop icon shrinks (in px) when it is being held
    
    let UPPER_R = 255.0                             // Gradient fill upper R value
    let UPPER_G = 255.0                             // Gradient fill upper G value
    let UPPER_B = 255.0                             // Gradient fill upper B value
    
    let LOWER_R = 255.0                             // Gradient fill lower R value
    let LOWER_G = 255.0                             // Gradient fill lower G value
    let LOWER_B = 255.0                             // Gradient fill lower B value
    
    
    let FADING_TIME = 0.75                          // Time in which a session selection button fades away
    let DISSAPEARING_TIME = 0.50                    // Time in which a session selection button dissapears off the screen
    
    var SEL_BUTTONS_LAT_OFFSET_S3: CGFloat!         // Session selection y coordinate for first levels of buttons
    var SEL_BUTTONS_LAT_OFFSET_S2: CGFloat!         // Session selection y coordinate for second levels of buttons
    var SEL_BUTTONS_VER_OFFSET_L1: CGFloat!         // Session selection lateral offset for size three levels
    var SEL_BUTTONS_VER_OFFSET_L2: CGFloat!         // Session selection lateral offset for size two levels
    
    var SEL_BUTTONS_SIZE: CGFloat!                  // Session selection button's size
    let SEL_BUTTON_FONT = "Avenir Next"             // Font name for session selection buttons
    let SEL_BUTTON_FONT_SIZE: CGFloat = 40          // Font size for session selection buttons
    
    
    let LABEL_FONT = "Avenir Next Ultra Light"      // BubbleTimer UILabel font name
    var LABEL_FONT_STARTING_SIZE: CGFloat!          // BubbleTimer UILabel font size
    let FONT_SIZE_RATIO = 5.0                       // The bubble_size/font_size ratio will always remain constant
    let CRITICAL_TIME_U_BOUND = 10.0                // Time at which the BubbleTimer UILabel will start changing colour
    let CRITICAL_TIME_L_BOUND = 1.0                 // Time at which the BubbleTimer UILabel will stop changing colour
    
    let LABEL_RED = 0.0                             // BubbleTimer UILabel R value
    let LABEL_GREEN = 0.0                           // BubbleTimer UILabel G value
    let LABEL_BLUE = 0.0                            // BubbleTimer UILabel B value
    
    let LABEL_CRIT_RED = 200.0                      // BubbleTimer UILabel R value
    let LABEL_CRIT_GREEN = 0.0                      // BubbleTimer UILabel G value
    let LABEL_CRIT_BLUE = 0.0                       // BubbleTimer UILabel B value
    
    
    let BUBBLE_SCREEN_RATIO_START = 0.45            // Initial size of a bubble expressed in percentage of screen width
    let BUBBLE_SCREEN_RATIO_END = 0.25              // Final size of a bubble expressed in percentage of screen width
    
    var BUBBLE_STARTING_Y: Double!                  // Y coordinate at which a bubble initially spwans (=SCREEN_HEIGHT + MARGIN)
    var BUBBLE_STARTING_SIZE: Double!               // Bubble starting size (=SCREEN_WIDTH * BUBBLE_SCREEN_RATIO_START)
    var BUBBLE_ENDING_SIZE: Double!                 // Bubble starting size (=SCREEN_WIDTH * BUBBLE_SCREEN_RATIO_END)
    var BUBBLE_ASPECT_RATIO: Double!                // Aspect ratio of the image used for the bubble (=height/width)
    
    let PRESENTATION_DURATION: TimeInterval = 5     // Duration of bubble presentation animation
    let SPRING_DAMPING = 0.75                       // Spring damping argument for bubble spring presentation animation
    let SPRING_VELOCITY = 1.15                      // Spring velocity argument for bubble spring presentation animation
    let CEILING_SPRING_DAMPING =  0.80              // Top most two bubbles need an ad-hoc spring effect
    let CEILING_SPRING_VELOCITY = 1.4               // Top most two bubbles need an ad-hoc spring effect
    
    
    let WARP_SPEED_FACTOR: Double = 1               // Constant only to be used during debug to speed up th timers
    let DEBUG_BUBBLE_POSITION = false               // Activate this flag to draw a square in the centre point of each BubbleTimer
}

// Refer to this variable to access the constants struct
var constants: constants_t = constants_t()
