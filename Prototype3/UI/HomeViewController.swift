//
//  HomeViewController.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 25/11/21.
//

/*
 * -- Main UIViewController module --
 * Holds the HomeViewController:UIViewController class to manage the main view controller of the app.
 *
 * Singleton: reference
 * Attrib: timers
 * Method: viewWillAppear(_ animated: Bool)
 * Method: viewDidLoad()
 * Method: addNewBubbleTimer(ofTimer timer: Int, isWasher: Bool)
 * Method: presentBubble(of newTimer: BubbleTimer, at finalY: CGFloat)
 * Method: reorderBubbles()
 * @IBAction: buttonPressed(_ sender: Any)
 * @IBAction: buttonPressCancel(_ sender: Any)
 * @IBAction: buttonPressedConfirm(_ sender: Any)
 */


import UIKit


class HomeViewController: UIViewController {
    
    // Reference for outer-scope accessing
    static var reference: HomeViewController!
    
    // This array will contain all the BubbleTimer instances at ny given time
    var timers: [BubbleTimer] = []
    
    // Reference to drop icon UIImageView
    @IBOutlet weak var dropUIImageView: UIImageView!
    @IBOutlet weak var dropWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropYcoordConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropXcoordConstraint: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        HomeViewController.reference = self
        super.viewDidLoad()
    }
    
    
    // MARK: These three functions deal with the drop-icon's behaviour as it is pressed / released
    @IBAction func buttonPressed(_ sender: Any) {
        // Button is being pressed: shrink drop icon
        UIView.animate(withDuration: 0.1, animations: {
            self.dropUIImageView.alpha = constants.DROP_ICON_PRESSED_ALPHA
            self.dropXcoordConstraint.constant += constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropYcoordConstraint.constant += constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropWidthConstraint.constant -= constants.DROP_ICON_RESIZE_CONSTANT
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func buttonPressCancel(_ sender: Any) {
        // Button has been released: restore drop icon's size
        UIView.animate(withDuration: 0.1, animations: {
            self.dropUIImageView.alpha = 1.0
            self.dropXcoordConstraint.constant -= constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropYcoordConstraint.constant -= constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropWidthConstraint.constant += constants.DROP_ICON_RESIZE_CONSTANT
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func buttonPressedConfirm(_ sender: Any) {
        // Button has been released: restore drop icon's size
        UIView.animate(withDuration: 0.1, animations: {
            self.dropUIImageView.alpha = 1.0
            self.dropXcoordConstraint.constant -= constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropYcoordConstraint.constant -= constants.DROP_ICON_RESIZE_CONSTANT/2.0
            self.dropWidthConstraint.constant += constants.DROP_ICON_RESIZE_CONSTANT
            self.view.layoutIfNeeded()
        })
    }
    
    
    // MARK: This function adds a new BubbleTimer instance and starts its timer
    func addNewBubbleTimer(ofTimer timer: Int, isWasher: Bool) {
        // Creating a new instance of the bubble-like timer UIView
        let newTimer = BubbleTimer(ofTime: timer, for: isWasher ? "washer" : "drier")
        
        // Dealing with screen positioning of created bubbleTimer
        // middlePoint represents the middle x coordinate of the half screen reserved for current bubble spawning
        let middlePoint = self.timers.count % 2 == 0 ? Int(constants.SCREEN_WIDTH / 4.0) : Int(constants.SCREEN_WIDTH - constants.SCREEN_WIDTH / 4.0)
        // deltaShift represents the left/right pixel shift of an initial random x coordinate.
        // Given that a bubble has to fit into 0.5 of the screen, and that each bubble has a
        // constants.BUBBLE_SCREEN_RATIO_START, we define this value as:
        let deltaShift = Int(constants.SCREEN_WIDTH * (0.5 - constants.BUBBLE_SCREEN_RATIO_START) / 2.0)
        
        // X coordinate of our bubble will be randomly generated each time
        let minimumX = middlePoint - deltaShift + (self.timers.count % 2 == 0 ? Int(constants.MARGIN/3.0) : 0)
        let maximumX = middlePoint + deltaShift - (self.timers.count % 2 != 0 ? Int(constants.MARGIN/3.0) : 0)
        newTimer.x_coord = CGFloat(Int.random(in: minimumX...maximumX)) - constants.BUBBLE_STARTING_SIZE/2.0
        newTimer.y_coord = getVerticalAllignment(amount: self.timers.count)
        
        // Finally, adding the bubble-like timer UIView to the current view controller
        newTimer.frame = CGRect.init(x: Double(newTimer.x_coord),
                                     y: constants.BUBBLE_STARTING_Y,
                                     width: constants.BUBBLE_STARTING_SIZE,
                                     height: constants.BUBBLE_STARTING_SIZE * constants.BUBBLE_ASPECT_RATIO)
        self.view.addSubview(newTimer)
        
        // MARK: If the appropriate flag is activated, a small red square is drawn in the middle of the bubble timers
        if constants.DEBUG_BUBBLE_POSITION == true {
            let crosshair = UIView()
            crosshair.frame = CGRect.init(x: newTimer.x_coord+constants.BUBBLE_STARTING_SIZE/2-2, y: newTimer.y_coord-2.0, width: 4, height: 4)
            crosshair.backgroundColor = UIColor.red
            self.view.addSubview(crosshair)
        }
        
        // newTimer is stored in the timer's array and its UIView is moved into viewm, finally the timer object is saved locally
        self.timers.append(newTimer)
        presentBubble(of: newTimer, at: newTimer.y_coord)
        ////////////
    }
    
    
    // MARK: Function in charge of animating the entry of a timer bubble
    func presentBubble(of newTimer: BubbleTimer, at finalY: CGFloat) {
        
        // Setting up animation parameters:
        // First two bubbles must hit the "ceiling" of the screen
        // Following bubbles will have a stronger "springing" effect
        let springWithDamping = timers.count <= 2 ? constants.CEILING_SPRING_DAMPING : constants.SPRING_DAMPING
        let springVelocity = timers.count <= 2 ? constants.CEILING_SPRING_VELOCITY : constants.SPRING_VELOCITY
        
        UIView.animate(withDuration: constants.PRESENTATION_DURATION,
                       delay: 0,
                       usingSpringWithDamping: springWithDamping,
                       initialSpringVelocity: springVelocity,
                       options: UIView.AnimationOptions(),
                       animations: { newTimer.layer.position.y = finalY },
                       completion: nil)
    }
    
    
    // MARK: This method is called when a bubble pops and all the others must be reordered
    func reorderBubbles() {
        // Reference keeper and flag
        var bubbleToRemove: BubbleTimer!
        var hasBeenFound = false
        
        // Coordinate switching variables
        var prec_x: CGFloat!
        var prec_y: CGFloat!
        
        for bubble in timers {
            if hasBeenFound {
                // Shift must be executed
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 4.0, options: [], animations: {
                    bubble.layer.position.x = prec_x  // + constants.BUBBLE_STARTING_SIZE - constants.BUBBLE_ENDING_SIZE
                    bubble.layer.position.y = prec_y
                }, completion: nil)
                
                // Placeholder variables
                let tmp_x = prec_x
                let tmp_y = prec_y
                
                // Switching coordinates values
                prec_x = bubble.x_coord
                prec_y = bubble.y_coord
                
                bubble.x_coord = tmp_x
                bubble.y_coord = tmp_y
            } else if bubble.timer.hasElapsed {
                // Target has been found
                bubbleToRemove = bubble
                hasBeenFound = true
                
                prec_x = bubble.x_coord
                prec_y = bubble.y_coord
            }
        }
        
        if let target = bubbleToRemove {
            // Remove the elapsed timer from the array
            var index = 0
            while timers.contains(target) {
                if timers[index] == target {
                    break
                }
                index += 1
            }
            timers.remove(at: index)
            target.removeFromSuperview()
            //target = nil
        } else {
            print("--- Bubble to remove couldn't be found in timers array")
        }
    }
}
