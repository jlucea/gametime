//
//  GTTimer.swift
//  GameTime
//
//  Created by Jaime Lucea.
//
//  This file contains the definition of the GTTimer class, a timer model designed for
//  tracking time for individual players within the GameTime app. The GTTimer class
//  provides properties and methods to start, stop, reset, and observe timer progress
//  in real time. Each GTTimer instance is customizable, supporting unique names,
//  colors, and varying maximum times, allowing for a flexible and reusable timer model
//  in the app.
//
//  The GTTimer class conforms to ObservableObject to support SwiftUI’s reactivity,
//  making it ideal for real-time updates in the user interface.
//

import Foundation
import SwiftUI

/// A timer model class used in the GameTime app to track and manage time for individual players.
///
/// `GTTimer` allows for setting an initial duration, custom color, and provides functionality
/// to start, stop, and reset timers, as well as observe progress updates. This class is designed
/// to be used with SwiftUI and supports real-time UI updates with `@Published` properties.
///
/// Example usage:
/// ```swift
/// let timer = GTTimer(name: "Player 1", color: .blue, maxTime: 60)
/// timer.start()
/// ```
///
public class GTTimer: ObservableObject {
    /// A unique identifier for each GTTimer instance.
    public let id = UUID()
    
    /// The name associated with this timer, typically representing a player.
    @Published public var name: String
    
    /// The color used for UI elements associated with this timer.
    @Published public var color: Color

    /// The total duration of the timer in seconds.
    @Published public var totalDuration: Int
    
    /// The current paused state of the GTTimer
    @Published public var isPaused: Bool
    
    /// The current remaining time in seconds. Updates as the timer counts down.
    @Published public var timeRemaining: Int
    
    private var timer: Timer?
    
    /// Initializes a GTTimer instance with a specified name, color, and maximum time.
    ///
    /// - Parameters:
    ///   - name: A `String` representing the name of the timer.
    ///   - color: A `Color` representing the timer's associated color.
    ///   - maxTime: An `Int` indicating the maximum time in seconds for this timer.
    init(name: String, color: Color, maxTime: Int) {
        self.name = name
        self.color = color
        self.totalDuration = maxTime
        self.isPaused = true
        self.timeRemaining = maxTime
        initTimer()
    }
    
    /// Initializes a GTTimer instance with a specified name, color, maximum time, and remaining time.
    ///
    /// This initializer allows setting a custom remaining time, useful when resuming a timer.
    ///
    /// - Parameters:
    ///   - name: A `String` representing the name of the timer.
    ///   - color: A `Color` representing the timer's associated color.
    ///   - maxTime: An `Int` indicating the maximum time in seconds for this timer.
    ///   - remainingTime: An `Int` indicating the time remaining in seconds when the timer starts.
    convenience init(name: String, color: Color, maxTime: Int, remainingTime: Int) {
        self.init(name: name, color: color, maxTime: maxTime)
        self.isPaused = true
        self.timeRemaining = remainingTime
        initTimer()
    }
    
    /// Creates a persistent timer
    private func initTimer() {
        // This ensures that only one Timer is ever active for a GTTimer instance.
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // Ensure it runs in `.common` mode to keep it active during UI interactions
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func start(){
        self.isPaused = false
        print("Timer '" + name + "' started")
    }
    
    func pause(){
        self.isPaused = true
        print("Timer '" + name + "' paused")
    }
    
    func resume(){
        if isPaused {
            self.isPaused = false
            print("Timer '" + name + "' resumed")
        }
    }
    
    private func tick() {
        guard !isPaused else { return }     // Only decrement if not paused
        DispatchQueue.main.async {
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.pause()    // Automatically pause if time runs out
            }
        }
    }
    
    //
    // Returns 0 to 1, where 1 is 100% completion (0 secs left)
    //
    func getProgress() -> Double {
        guard totalDuration > 0 else { return 1 }
        return 1-Double(timeRemaining)/Double(totalDuration)
    }
    
    //
    // Returns String representation of current time e.g. 01:04:48
    //
    func getTimeString() -> String {
        let time = TimeInterval(timeRemaining)
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}
