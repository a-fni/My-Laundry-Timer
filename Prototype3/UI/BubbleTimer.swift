//
//  BubbleTimer.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 25/11/21.
//

/*
 * -- Main module to deal with bubble shaped timers --
 * Holds the BubbleTimer:UIView class whose objects are UIViews with a UIImageView and a UILabel
 *
 * Attrib: timer
 * Attrib: bubbleUIImage
 * Attrib: bubbleUIImageView
 * Attrib: timerUILabel
 * Attrib: currR
 * Attrib: currG
 * Attrib: currB
 * Attrib: x_coord
 * Attrib: y_coord
 * Attrib: currSize
 * init(ofTime time: Int, for deviceType: String)
 * Method: setTimeDependantColour(withTimeLeft timeLeft: Double, isFirstTime first: Bool=false)
 * Protocol: timeRemainingOnTimer(_ timer: TimerClass, timeRemaining timeLeft: TimeInterval)
 * Protocol: timerHasFinished(_ timer: TimerClass)
 */


import UIKit


class BubbleTimer: UIView, TimerProtocol {
    
    // BUbbleTimer's timer and popping-sound objects
    var timer: TimerClass!
    var poppingSound: SoundManager!
    
    // Bubble image UIImage, its relative UIImageView and UILabel for showing time left
    var bubbleUIImage: UIImage!
    var bubbleUIImageView: UIImageView!
    var timerUILabel: UILabel!
    
    // UILabel text colour RGB values
    var currR: Double!
    var currG: Double!
    var currB: Double!
    
    // Coordinates on the main view controller UIView
    var x_coord: CGFloat!
    var y_coord: CGFloat!
    var currSize: CGFloat!
    
    
    // MARK: Will initialize bubble, with correct image, label, size and position
    init(ofTime time: Int, for deviceType: String) {
        super.init(frame: CGRect())
        
        // Initializing current bubble's initial size
        currSize = constants.BUBBLE_STARTING_SIZE
        
        // Setting up the timer
        timer = TimerClass(time: Double(time * 60), deviceType: deviceType)
        timer.delegate = self
        
        // Creating UIImage and UIImageView objects
        bubbleUIImage = UIImage(named: "Bubble")
        bubbleUIImageView = UIImageView(image: bubbleUIImage!)
        bubbleUIImageView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: constants.BUBBLE_STARTING_SIZE,
                                        height: constants.BUBBLE_STARTING_SIZE * constants.BUBBLE_ASPECT_RATIO)
        self.addSubview(bubbleUIImageView)
        
        // Creating a UILabel for the timer
        timerUILabel = UILabel()
        timerUILabel.text = formatTimeText(givenMinutes: time)
        timerUILabel.font = UIFont.init(name: constants.LABEL_FONT, size: constants.LABEL_FONT_STARTING_SIZE)
        setTimeDependantColour(withTimeLeft: Double(time)*60, isFirstTime: true)
        timerUILabel.textAlignment = NSTextAlignment.justified
        timerUILabel.textAlignment = NSTextAlignment.center
        timerUILabel.frame = CGRect(x: 0,
                                    y: 0,
                                    width: constants.BUBBLE_STARTING_SIZE,
                                    height: constants.BUBBLE_STARTING_SIZE * constants.BUBBLE_ASPECT_RATIO)
        self.addSubview(timerUILabel)
        
        // Preparing sound for when the bubble will pop
        poppingSound = SoundManager()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: This method is in charge of gradually tuning the UILabel text colour, based on time left 
    func setTimeDependantColour(withTimeLeft timeLeft: Double, isFirstTime first: Bool=false) {
        
        // If first is true, we are calling the function in order to set the initial colour of the UILabel
        // If this is not the first time we try to set the colour of the label, we are in a critical-time-left scenario
        if first {
            
            // Checking if timer has started above or below the critical-time-left ceiling
            if timeLeft >= 60 * constants.CRITICAL_TIME_U_BOUND {
                // Value above critical-time-left: start with default colours
                self.currR = constants.LABEL_RED
                self.currG = constants.LABEL_GREEN
                self.currB = constants.LABEL_BLUE
            } else if timeLeft <= 60 * constants.CRITICAL_TIME_L_BOUND {
                // Value below lower critical-time-left bound: start with ending colours
                self.currR = constants.LABEL_CRIT_RED
                self.currG = constants.LABEL_CRIT_GREEN
                self.currB = constants.LABEL_CRIT_BLUE
            } else {
                // Anything in between has to be properly calculated
                let deltaT = (constants.CRITICAL_TIME_U_BOUND - constants.CRITICAL_TIME_L_BOUND) * 60
                let T = constants.CRITICAL_TIME_U_BOUND * 60 - timeLeft
                
                // Calculating R, G and B values change
                let deltaR = constants.LABEL_CRIT_RED - constants.LABEL_RED
                let deltaG = constants.LABEL_CRIT_GREEN - constants.LABEL_GREEN
                let deltaB = constants.LABEL_CRIT_BLUE - constants.LABEL_BLUE
                
                // Calculate rate of change of R, G and B values
                let speedR = deltaR / deltaT
                let speedG = deltaG / deltaT
                let speedB = deltaB / deltaT
                
                // Compute current R, G and B values based on timeLeft
                self.currR = speedR * T
                self.currG = speedB * T
                self.currB = speedG * T
            }
        
        } else {
            // Calculating how much time is left
            let deltaT = timeLeft - constants.CRITICAL_TIME_L_BOUND * 60
            
            // Calculating R, G and B values change
            let deltaR = constants.LABEL_CRIT_RED - self.currR
            let deltaG = constants.LABEL_CRIT_GREEN - self.currG
            let deltaB = constants.LABEL_CRIT_BLUE - self.currB
            
            // Calculate rate of change of R, G and B values
            let speedR = deltaR / deltaT
            let speedG = deltaG / deltaT
            let speedB = deltaB / deltaT
            
            // Compute current R, G and B values based on timeLeft
            self.currR += speedR
            self.currG += speedB
            self.currB += speedG
        }
        
        self.timerUILabel.textColor = UIColor(red: self.currR/255.0,
                                              green: self.currG/255.0,
                                              blue: self.currB/255.0,
                                              alpha: 1.0)
    }
    
    
    // MARK: BubbleTimer protocol implementation - following function called at each timer tick
    func timeRemainingOnTimer(sender timer: TimerClass, timeRemaining timeLeft: TimeInterval) {
        // Updating timerUILabel text with current time left
        timerUILabel.font = UIFont.init(name: constants.LABEL_FONT, size: currSize/constants.FONT_SIZE_RATIO)
        timerUILabel.text = formatTimeText(givenSeconds: Int(timeLeft))
        
        // Depending on time left, the font colour will gradually change to red-ish
        if Double(timeLeft) > 60 * constants.CRITICAL_TIME_L_BOUND && Double(timeLeft) < 60 * constants.CRITICAL_TIME_U_BOUND {
            setTimeDependantColour(withTimeLeft: timeLeft)
        }

        // Computing 1 tick bubble resize value. This is done calculating the size variation (between
        // current size and final size), which is then divided by the time left. The result represents
        // the speed of resize, which for one second is exactly the resize delta we want
        let deltaSize = (currSize - constants.BUBBLE_ENDING_SIZE) / Double(timeLeft)
        currSize -= deltaSize

        // Animating smoothly the reisizing of the UIImageView
        UIView.animate(withDuration: 1/constants.WARP_SPEED_FACTOR, animations: {
            // Updating whole frame withing HomeViewController
            self.frame.size.width = CGFloat(self.currSize)
            self.frame.size.height = CGFloat(self.currSize * constants.BUBBLE_ASPECT_RATIO)
            
            // Forcing layer's position, so that it doesn't shift while frame is being resized
            self.layer.position.x = self.x_coord + constants.BUBBLE_STARTING_SIZE/2
            self.layer.position.y = self.y_coord
            
            // Updating UIImageView
            self.bubbleUIImageView.frame.size.width = CGFloat(self.currSize)
            self.bubbleUIImageView.frame.size.height = CGFloat(self.currSize * constants.BUBBLE_ASPECT_RATIO)
            
            // Updating UILabel
            self.timerUILabel.layer.position.x = self.timerUILabel.layer.position.x - deltaSize/2
            self.timerUILabel.layer.position.y = self.timerUILabel.layer.position.y - deltaSize/2
        })
    }
    
    
    // MARK: BubbleTimer protocol implementation - following function called on timer elapsed event
    func timerHasFinished(sender timer: TimerClass) {
        // Play notification sound
        poppingSound.playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.poppingSound.audioPlayer?.stop()
        }
        
        // Animate bubble popping
        UIView.animate(withDuration: 0.1, animations: {

            /* ----------------------------------------- */
            /* ADD AN ANIMATION FOR WHEN THE BUBBLE POPS */
            /* ----------------------------------------- */

        }, completion: {(finished: Bool) in
            // Resetting the timers parameters
            self.bubbleUIImageView = nil
            self.bubbleUIImage = nil
            self.timer.hasElapsed = true

            // Reordering all other bubbles
            HomeViewController.reference.reorderBubbles()
        })
    }
}
