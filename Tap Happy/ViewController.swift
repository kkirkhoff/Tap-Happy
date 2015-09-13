//
//  ViewController.swift
//  Tap Happy
//
//  Created by Work on 9/6/15.
//  Copyright (c) 2015 Kevin Kirkhoff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var happyFace: UIImageView!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var screenBounds: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var tapCount: Int = 0                                           // Number of times user hit the image
    var missedTapsCount: Int = 0                                    // Number of times user missed the image
    var orientation = UIDevice.currentDevice().orientation          // Which way is the device positioned? (Landscape/Portrait)
    var startTime = NSTimeInterval()                                // The moment the tap the Start button
    var timer = NSTimer()                                           // Uh...a stopwatch object
    var elapsedTime: NSTimeInterval = 0                             // The time elapsed from tapping the Start button
    var myPreviousTime: UInt32 = 999999                             // What was my previous quickest time?
    var myTime: UInt32 = 0                                          // Time of the current game
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Determine the dimensions of the screen
        computeScreenBounds()
        
        // Initialize the image off screen and invisible
        happyFace.frame.origin.x = screenWidth + 100
        happyFace.frame.origin.y = screenHeight + 100
        happyFace.hidden = true
        
    }
    
    // Called when the Start button is pressed
    @IBAction func startGame(sender: UIButton)
    {
        // Since the Start and Stop is the same button...
        if sender.currentTitle == "Start"
        {
            // Hide instructions and button
            instructionLabel.hidden = true
            sender.hidden = true
            
            // Show the tap count and image
            tapLabel.hidden = false
            happyFace.hidden = false
            
            // Reset the tap counters
            tapCount = 0
            missedTapsCount = 0
            
            // Change the button text to say Stop
            sender.setTitle("Stop", forState: UIControlState.Normal)
            
            // Move the image onto the screen (remember I initialized it offscreen in viewDidLoad
            moveImage()
            
            // Start a timer and have it repeat every .01 second.
            let aSelector:Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
        else
        {
            // If the user pressed the Stop button, stop the game.
            // (currently not an issue because the game stops in 10 taps of the image.
            stopGame()
            
        }
        
    }
    
    // This is called when the game stops, either but the user tapping the Stop button or automatically
    func stopGame()
    {
        // Change the button text to say Start
        startButton.setTitle("Start", forState: UIControlState.Normal)
        
        // Make the button and instructions visible
        startButton.hidden = false
        instructionLabel.hidden = false
        
        // Hide the image
        happyFace.hidden = true
        
        // Move the image off the screen
        happyFace.frame.origin.x = screenWidth + 100
        happyFace.frame.origin.y = screenHeight + 100
        
        // New high score?
        if myTime < myPreviousTime
        {
            highScoreLabel.text = timerLabel.text
            myPreviousTime = myTime
        }
        
        // Stop the timer
        timer.invalidate()
    }
    
    // This determines the size of the screen
    func computeScreenBounds()
    {
        // Get the screen size
        screenBounds = UIScreen.mainScreen().bounds
        screenWidth = screenBounds.size.width
        screenHeight = screenBounds.size.height
    }
    
    // This is called every time the user taps the screen
    @IBAction func viewTapped(sender: UITapGestureRecognizer)
    {
        let tapPoint = sender.locationInView(self.view)       // Get the point on the screen
        
        let tapped = collision(tapPoint)                      // Determine if the user tapped the image
        
        // If the image was tapped, move it somewhere else
        if (tapped)
        {
            moveImage()
        }
    }
    
    // This determines if the user tapped the image
    func collision(tapPoint:CGPoint) -> Bool
    {
        var hitImage: Bool = false
        
        // Set local variables for the size and origin of the image. All this does is make the IF statement easier to read.
        let width  = happyFace.frame.size.width
        let height = happyFace.frame.size.height
        let x = happyFace.frame.origin.x
        let y = happyFace.frame.origin.y
        
        // If the tap point is within the bounds of the image...
        if (tapPoint.x > x && tapPoint.x < x+width) && (tapPoint.y > y && tapPoint.y < y+height)
        {
            hitImage = true                                               // Register the hit as TRUE
            tapCount++                                                    // Update the number of times the user has tapped the image
            tapLabel.text = "\(tapCount)/\(tapCount+missedTapsCount)"     // Build the string for displaying
            
            // If the user has tapped the image 10 times, stop the game
            if (tapCount == 10)
            {
                stopGame()
            }
        }
        else
        {
            // The user missed the image
            hitImage = false
            missedTapsCount++
        }
        
        return hitImage
    }
    
    
    // This function basically gets the time, subtracts the original time and builds a display string.
    func updateTime()
    {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        // Find the difference between current time and start time
        elapsedTime = currentTime - startTime
        
        // Calculate the minutes in elapsed time
        let minutes = UInt32(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        // Calculate the seconds in elapsed time
        let seconds = UInt32(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        // Find the fraction of millisseconds to be displayed
        let fraction = UInt32(elapsedTime * 100)
        
        // Add leading zeros form minutes, seconds, and milliseconds
        let strMinutes  = String(format: "%02d", minutes)
        let strSeconds  = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        
        myTime = UInt32((minutes * 1000) + (seconds * 100) + (fraction))
    }
    
    // This function moves the image around the screen. It makes sure no part of the image will be offscreen.
    func moveImage()
    {
        // If the screen orientation has changed, compute new screen bounds
        // ***** I don't use this right now because I had to turn AutoLayout off. It only displays as Portrait *****
        let localOrientation = UIDevice.currentDevice().orientation
        if (localOrientation != orientation)
        {
            computeScreenBounds()
            orientation = localOrientation
        }
        
        // Compute a new X,Y location for the image.
        var newX = CGFloat(arc4random_uniform(UInt32(screenWidth)))
        var newY = CGFloat(arc4random_uniform(UInt32(screenHeight)))
        
        // Don't let any part of the image be offscreen
        if newX >= screenWidth - happyFace.frame.size.width
        {
            newX = screenWidth - happyFace.frame.size.width
        }
        
        if newY >= screenHeight - happyFace.frame.size.height
        {
            newY = screenHeight - happyFace.frame.size.height
        }
        
        
        // Assign the image's new position and update counter label
        happyFace.frame.origin.x = CGFloat(newX)
        happyFace.frame.origin.y = CGFloat(newY)
        
    }
}

