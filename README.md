![GameTime - Photo Screenshot](https://user-images.githubusercontent.com/26114098/200882056-c0c2aba2-8eab-477e-8ad9-b4cc67eef9ff.png)

# GameTime
GameTime is an iOS timer app for board game enthusiasts.

# Features

GameTime allows the user to create a number of timers, each of them having a name, a color and a duration. 

When the session starts, the user can switch between timers by pressing the next button or by tapping on a specific timer. Any of these actions will pause the active timer and resume the next one. 

GameTime reacts to changes in the state of the app, discounting from the active timer the time that has passed while it was running in the background.

The user can also delete timers at any time.

![iPad Pro in space grey or silver color_Simulator Screen Shot - iPad Pro (12 9-inch) (6th generation) - 2022-11-09 at 13 27 37](https://user-images.githubusercontent.com/26114098/200887822-6fb0b9df-26e7-42d4-9cd0-0436d1292a8a.png)

# Technical Details

GameTime is developed in SwiftUI. Several views in the app update simultaneously based on a single source of truth: the active timer's state.

<img width="320" height="782" alt="Simulator Screenshot - iPhone 17 - 2026-03-16 at 10 04 01" src="https://github.com/user-attachments/assets/6fb37e34-8271-4037-aded-5755713f61bc" />

# Copyright

GameTime was developed by Jaime Lucea for non-commercial purposes. The code can be copied and shared freely, but the app should't be used for commercial purposes.

The GameTime brand and logo are registered to Jaime Lucea.
