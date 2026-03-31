//
//  ProgrammesViewController.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 25/11/21.
//

/*
 * -- Main Session selection module --
 * Contains the ProgrammesViewController:UIViewController class for the session creation/selection view
 *
 * Method: viewDidLoad()
 * Method: washerModeSelected(_ sender: UIButton)
 * Method: washerTempSelected(_ sender: UIButton)
 * Method: drierTempSelected(_ sender: UIButton)
 * Method: restoreDeviceSelection()
 * Method: washerModeSelection()
 * Method: washerTempSelection()
 * Method: drierTempSelection()
 * Method: createButtons(amount: Int, titles: [String], colours: [[Double]], callback: Selector)
 * Method: destroyButtons(target: UIButton)
 * Method: addNewTimerTest(_ timer: Int)
 * Method: destroyButtons(target: UIButton, callback: @escaping ()->())
 * @IBAction: startWasherSelection(_ sender: Any)
 * @IBAction: StartDrierSelection(_ sender: Any)
 * @IBAction: startTimer(_ sender: Any)
 */
 
import UIKit

 
class ProgrammesViewController: UIViewController {
    
    // Washer button and vertical constraint
    @IBOutlet weak var washerUIButton: UIButton!
    @IBOutlet weak var washerNSLayoutConstraint: NSLayoutConstraint!
    
    // Drier button and vertical constraint
    @IBOutlet weak var drierUIButton: UIButton!
    @IBOutlet weak var drierNSLayoutConstraint: NSLayoutConstraint!
    
    // Interface button references
    @IBOutlet weak var goBackUIButton: UIButton!
    
    // Other general purpose attributes
    var initialConstraintValue: CGFloat!
    var isWasher: Bool!
    var selections: [Int] = []
    var buttonsArray: [UIButton] = []
    
    
    override func viewDidLoad() {
        // Fetching the device selection button's constraint value
        initialConstraintValue = drierNSLayoutConstraint.constant
        
        // Hiding the go-back portal
        goBackUIButton.isEnabled = false
        goBackUIButton.alpha = 0.0
        
        super.viewDidLoad()
    }

    
    // MARK: This method will initiate the washer session selection
    @IBAction func startWasherSelection(_ sender: Any) {
        isWasher = true
        goBackUIButton.isEnabled = true
        
        // One button fades, the other dissapears
        UIView.animate(withDuration: constants.DISSAPEARING_TIME, animations: {
            self.goBackUIButton.alpha = 1
            self.washerUIButton.alpha = 0
            self.drierNSLayoutConstraint.constant = constants.SCREEN_HEIGHT
            self.view.layoutIfNeeded()
        }, completion: {(finished: Bool) in
            self.washerModeSelection()
        })
    }
    
    
    // MARK: This method will initiate the drier session selection
    @IBAction func StartDrierSelection(_ sender: Any) {
        isWasher = false
        goBackUIButton.isEnabled = true
        
        // One button fades, the other dissapears
        UIView.animate(withDuration: constants.DISSAPEARING_TIME, animations: {
            self.goBackUIButton.alpha = 1
            self.washerNSLayoutConstraint.constant = constants.SCREEN_HEIGHT
            self.view.layoutIfNeeded()
            self.drierUIButton.alpha = 0
        }, completion: {(finished: Bool) in
            self.drierTempSelection()
        })
    }
    
    
    // MARK: Function called when the user wants to undo a selection
    @IBAction func goBack(_ sender: Any) {
        // Two cases have to be distinguished:
        let progress = selections.count
        
        // If selections have been done, then remove the last one
        if progress >= 1 {
            _ = selections.popLast()
        }
        
        // Removing all buttons from the view
        for button in buttonsArray {
            UIView.animate(withDuration: constants.DISSAPEARING_TIME, animations: {
                button.layer.position.y = constants.SCREEN_HEIGHT
                button.layer.position.x = constants.SCREEN_WIDTH / 2
            }, completion: {(finished: Bool) in button.removeFromSuperview()})
        }
        
        // Based on the situation, the most appropriate page is redrawn
        if isWasher == true && progress == 2 {
            washerTempSelection()
        } else if isWasher == true && progress == 1 {
            washerModeSelection()
        } else if progress == 1 {
            drierTempSelection()
        } else {
            restoreDeviceSelection()
        }
    }
    
    
    // MARK: Called when washer mode of operation has been selected
    @objc func washerModeSelected(_ sender: UIButton) {
        // Removing buttons from screen
        destroyButtons(target: sender, callback: {self.washerTempSelection()})
        
        // Memorising the selection made
        selections.append(buttonsArray.firstIndex(of: sender)!)
    }
    
    
    // MARK: Called when washer temperature has been selected
    @objc func washerTempSelected(_ sender: UIButton) {
        // Memorising the selection made
        selections.append(buttonsArray.firstIndex(of: sender)!)
        
        // Removing buttons from screen
        destroyButtons(target: sender, callback: {self.startTimer()})
    }
    
    
    // MARK: Called when drier temperature has been selected
    @objc func drierTempSelected(_ sender: UIButton) {
        // Memorising the selection made
        selections.append(buttonsArray.firstIndex(of: sender)!)
        
        // Removing buttons from screen
        destroyButtons(target: sender, callback: {self.startTimer()})
    }
    
    
    // MARK: Function that restores the device selection phase by reinstalling washerUIButton and drierUIButton
    func restoreDeviceSelection() {
        
        // Based on what device had been selected, represent fading-in / animating the appropriate buttons
        if isWasher == true {
            UIView.animate(withDuration: constants.DISSAPEARING_TIME, delay: 0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 4.0,
                           options: [], animations: {
                self.goBackUIButton.alpha = 0.0
                self.washerUIButton.alpha = 1.0
                self.drierNSLayoutConstraint.constant = self.initialConstraintValue
                self.view.layoutIfNeeded()
            }, completion: {(finished: Bool) in self.goBackUIButton.isEnabled = false})
        } else {
            UIView.animate(withDuration: constants.DISSAPEARING_TIME, delay: 0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 4.0,
                           options: [], animations: {
                self.goBackUIButton.alpha = 0.0
                self.drierUIButton.alpha = 1.0
                self.washerNSLayoutConstraint.constant = self.initialConstraintValue
                self.view.layoutIfNeeded()
            }, completion: {(finished: Bool) in self.goBackUIButton.isEnabled = false})
        }
        
        // Resetting variables
        isWasher = nil
        selections = []
        buttonsArray = []
    }
    
    
    // MARK: Creates three buttons and presents them in order to select the washer's mode of operation
    func washerModeSelection() {
        // Emptying the buttonsArray array
        buttonsArray = []
        
        // Setting up the parameters of the three buttons
        let titles = ["A", "B", "C"]
        let colours = [[255.0, 200.0, 0.0],
                       [255.0, 150.0, 0.0],
                       [255.0, 100.0, 0.0]]
        
        // Creating the three buttons
        createButtons(amount: 3, titles: titles, colours: colours, callback: #selector(self.washerModeSelected))
        
        // Presenting the buttons with the appropriate animation
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 3, options: [], animations: {
            self.buttonsArray[0].layer.position.x -= constants.SEL_BUTTONS_LAT_OFFSET_S3
            self.buttonsArray[0].layer.position.y = constants.SEL_BUTTONS_VER_OFFSET_L1
            
            self.buttonsArray[1].layer.position.y = constants.SEL_BUTTONS_VER_OFFSET_L1
            
            self.buttonsArray[2].layer.position.x += constants.SEL_BUTTONS_LAT_OFFSET_S3
            self.buttonsArray[2].layer.position.y = constants.SEL_BUTTONS_VER_OFFSET_L1
        }, completion: nil)
    }
    
    
    // MARK: Creates six buttons and presents them in order to select the washer's temperature
    func washerTempSelection() {
        // Emptying the buttonsArray array
        buttonsArray = []
        
        // Setting up the parameters of the three buttons
        let titles = ["30", "60", "90", "60*", "30*", "Low"]
        let colours = [[255.0, 200.0, 0.0],
                       [255.0, 150.0, 0.0],
                       [255.0, 100.0, 0.0],
                       [200.0, 50.0, 50.0],
                       [150.0, 50.0, 100.0],
                       [100.0, 50.0, 150.0]]
        
        // Creating the six buttons
        createButtons(amount: 6, titles: titles, colours: colours, callback: #selector(self.washerTempSelected))
        
        // Presenting the buttons with the appropriate animation
        for (index, button) in buttonsArray.enumerated() {
            
            // Computing x coordinate offset for current button
            let x_offset: CGFloat!
            switch index {
            case 0, 3:
                x_offset = -constants.SEL_BUTTONS_LAT_OFFSET_S3
            case 1, 4:
                x_offset = 0
            case 2, 5:
                x_offset = constants.SEL_BUTTONS_LAT_OFFSET_S3
            default:
                fatalError("Something went wrong with the button's amount...")
            }
            
            // Computing y coordinate (alias, height) for current button
            let y_coord: CGFloat = index < 3 ? constants.SEL_BUTTONS_VER_OFFSET_L1 : constants.SEL_BUTTONS_VER_OFFSET_L2
            
            // Animating the appearence of current button
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 3, options: [], animations: {
                button.layer.position.x += x_offset
                button.layer.position.y = y_coord
            }, completion: nil)
        }
    }
    
    
    // MARK: Creates five buttons and presents them in order to select the drier's temperature
    func drierTempSelection() {
        // Emptying the buttonsArray array
        buttonsArray = []
        
        // Setting up the parameters of the three buttons
        let titles = ["1", "2", "3", "4", "5"]
        let colours = [[255.0, 200.0, 0.0],
                       [255.0, 150.0, 0.0],
                       [255.0, 100.0, 0.0],
                       [200.0, 50.0, 50.0],
                       [150.0, 50.0, 100.0]]
        
        // Creating the five buttons
        createButtons(amount: 5, titles: titles, colours: colours, callback: #selector(self.drierTempSelected))

        // Presenting the buttons with the appropriate animation
        for (index, button) in buttonsArray.enumerated() {
            
            // Computing x coordinate offset for current button
            let x_offset: CGFloat!
            switch index {
            case 0:
                x_offset = -constants.SEL_BUTTONS_LAT_OFFSET_S3
            case 1:
                x_offset = 0
            case 2:
                x_offset = constants.SEL_BUTTONS_LAT_OFFSET_S3
            case 3:
                x_offset = -constants.SEL_BUTTONS_LAT_OFFSET_S2
            case 4:
                x_offset = constants.SEL_BUTTONS_LAT_OFFSET_S2
            default:
                fatalError("Something went wrong with the button's amount...")
            }
            
            // Computing y coordinate (alias, height) for current button
            let y_coord = index < 3 ? constants.SEL_BUTTONS_VER_OFFSET_L1 : constants.SEL_BUTTONS_VER_OFFSET_L2
            
            // Animating the appearence of current button
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 3, options: [], animations: {
                button.layer.position.x += x_offset
                button.layer.position.y = y_coord!
            }, completion: nil)
        }
    }
    
    
    // MARK: This function is in charge of creating an arbitrary number of buttons with the proper parameters
    func createButtons(amount: Int, titles: [String], colours: [[Double]], callback: Selector) {
        // Emptying the buttonsArray array
        buttonsArray = []
        
        // Creating the N buttons and placing them outside the screen
        for i in 0...(amount-1) {
            let modeButton = UIButton()
            modeButton.backgroundColor = UIColor(red: colours[i][0]/255.0,
                                                 green: colours[i][1]/255.0,
                                                 blue: colours[i][2]/255.0,
                                                 alpha: 1.0)
            modeButton.setTitle(titles[i], for: .normal)
            modeButton.titleLabel?.font = UIFont(name: constants.SEL_BUTTON_FONT, size: constants.SEL_BUTTON_FONT_SIZE)
            modeButton.layer.cornerRadius = constants.SEL_BUTTONS_SIZE / 2
            modeButton.frame = CGRect(x: (constants.SCREEN_WIDTH - constants.SEL_BUTTONS_SIZE) / 2,
                                      y: constants.SCREEN_HEIGHT,
                                      width: constants.SEL_BUTTONS_SIZE,
                                      height: constants.SEL_BUTTONS_SIZE)
            modeButton.addTarget(self, action: callback, for: .touchUpInside)
            self.view.addSubview(modeButton)
            buttonsArray.append(modeButton)
        }
    }
    
    
    // MARK: This function is in charge of animating the dissapearing of all buttons after a choice has been made
    func destroyButtons(target: UIButton, callback: @escaping ()->()) {
        // Removing the buttons from the screen based on their role
        
        UIView.animate(withDuration: constants.FADING_TIME, animations: {target.alpha = 0.0}, completion: {(finished: Bool) in
            target.removeFromSuperview()
            callback()
        })
        for button in buttonsArray {
            if button != target {
                UIView.animate(withDuration: constants.DISSAPEARING_TIME, animations: {
                    button.layer.position.y = constants.SCREEN_HEIGHT
                    button.layer.position.x = (constants.SCREEN_WIDTH) / 2
                }, completion: {(finished: Bool) in button.removeFromSuperview()})
            }
        }
    }
    
    
    // MARK: Function called when session selection is complete, and a new timer can be started
    func startTimer() {
        // Computing time for next timer
        let timeOfTimer: Int!
        if isWasher {
            timeOfTimer = washerProgrammesDatabase[selections[0]][selections[1]]
        } else {
            timeOfTimer = drierProgrammesDatabase[selections[0]]
        }
        // Close the view
        self.dismiss(animated: true, completion: nil)
        
        // Advise HomeViewController that a new timer has to be added
        HomeViewController.reference.addNewBubbleTimer(ofTimer: timeOfTimer, isWasher: isWasher)
    }
    
    
    // MARK: Adds a new timer of time "timer". To be used  only for testing / debugging
    func addNewTimerTest(_ timer: Int) {
        self.dismiss(animated: true, completion: nil)
        HomeViewController.reference.addNewBubbleTimer(ofTimer: timer, isWasher: true)
    }
}
