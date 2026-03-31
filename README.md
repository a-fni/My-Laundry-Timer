# My Laundry Timer

A native iOS application written in Swift for tracking concurrent laundry appliance cycles. The app provides a fully custom, animated UI where each active timer is represented as a shrinking bubble that visually communicates remaining time, and fires both a local push notification and an in-app audio alert on completion.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration & Tuning](#configuration--tuning)
- [Laundry Programme Databases](#laundry-programme-databases)
- [Known Limitations & Future Work](#known-limitations--future-work)
- [License](#license)

---

## Overview

My Laundry Timer allows users to start multiple simultaneous laundry cycle timers — one per washer or dryer load — each displayed as an animated bubble that continuously shrinks as time elapses. When a cycle finishes, the bubble pops, an audio cue plays, and a local notification fires even if the app is backgrounded.

The session selection flow is a simple multi-step state machine: the user selects the appliance type (washer or dryer), then a mode or heat level, and the corresponding cycle duration is looked up from a hardcoded programme database. Multiple timers can be active at any time and are laid out in a two-column grid that rebalances itself when a timer completes.

---

## Features

**Concurrent timer management**
Up to N bubble timers can run simultaneously. Each is laid out in alternating left/right columns with randomised horizontal placement within its lane and vertical spacing computed recursively.

**Custom animated BubbleTimer view**
`BubbleTimer` is a `UIView` subclass that:
- Shrinks its frame linearly from `BUBBLE_SCREEN_RATIO_START` (45% of screen width) to `BUBBLE_SCREEN_RATIO_END` (25% of screen width) over the full cycle duration.
- Interpolates the countdown label colour from black toward a critical red between the `CRITICAL_TIME_U_BOUND` (10 min) and `CRITICAL_TIME_L_BOUND` (1 min) thresholds.
- Formats remaining time as `MM:SS`, collapsing the minute component when under one minute.

**Physics-based presentation animations**
Bubbles enter from below the screen using `UIView` spring animations. The first two bubbles use ceiling-tuned spring parameters (`CEILING_SPRING_DAMPING`, `CEILING_SPRING_VELOCITY`) to produce a tighter bounce; subsequent bubbles use a looser spring for visual variety.

**Local notifications**
`NotificationClass` wraps `UNUserNotificationCenter` and schedules a `UNTimeIntervalNotificationTrigger` at timer creation. Each notification receives a unique integer identifier via a global counter so multiple concurrent notifications do not collide. Permission is requested once on first launch.

**Audio feedback**
`SoundManager` wraps `AVAudioPlayer`, loading `ding.mp3` from the app bundle at initialisation. Playback is triggered on timer completion and stopped two seconds later. Audio session category is set to `.playback` so the sound plays even in silent mode.

**Background task support**
`AppDelegate` calls `beginBackgroundTask` on `applicationWillResignActive` to request extra execution time when the app moves to the background, giving in-flight timers time to fire their notifications before the process is suspended.

**Washer programme selection**
Three washer modes (A, B, C) × six temperature settings (30°, 60°, 90°, 60°\*, 30°\*, Low) with durations stored in a 3×6 matrix.

**Dryer heat level selection**
Five heat levels (1–5) with durations stored in a flat array.

---

## Architecture

The codebase is organised into three functional layers with no external dependencies.

### UI Layer (`UI/`)

**`HomeViewController`**
The root view controller. It owns a `[BubbleTimer]` array and is responsible for:
- Instantiating and laying out new `BubbleTimer` instances via `addNewBubbleTimer(ofTimer:isWasher:)`.
- Computing spawn coordinates: X is randomised within the half-screen lane assigned to each new timer; Y is computed by `getVerticalAllignment(amount:)`.
- Animating bubble entry via `presentBubble(of:at:)`.
- Reordering the remaining bubbles after one pops via `reorderBubbles()`, which walks the array and animates each subsequent bubble into the vacated slot using a spring animation.
- Exposing a static `reference` singleton so `BubbleTimer` can call back into the controller on completion without requiring a delegate.

**`ProgrammesViewController`**
The session creation modal. It implements a multi-step selection flow as a manual state machine driven by the `selections: [Int]` accumulator. At each step it calls `createButtons(amount:titles:colours:callback:)` to programmatically instantiate, position, and animate selection buttons, then `destroyButtons(target:callback:)` to remove them before transitioning to the next step. The `goBack` action pops the last selection and redraws the appropriate step. When all selections are complete, `startTimer()` looks up the duration in the relevant programme database and calls back into `HomeViewController`.

**`BubbleTimer`**
A `UIView` subclass and `TimerProtocol` conformer. It manages its own internal `TimerClass` instance, a `UIImageView` for the bubble graphic, a `UILabel` for the countdown, and a `SoundManager`. On each tick from `timeRemainingOnTimer`, it computes the per-tick frame shrink delta and animates the resize. On `timerHasFinished`, it plays the sound, clears its image references, sets `timer.hasElapsed = true`, and calls `HomeViewController.reference.reorderBubbles()`.

### Timer Layer (`TimerManager/`)

**`TimerClass`**
A thin wrapper around `Foundation.Timer`. It stores `startTime: Date` and at each tick computes `elapsedTime` as `-startTime.timeIntervalSinceNow * WARP_SPEED_FACTOR`, which makes the timer robust to background suspension (wall-clock based rather than tick-counting). It dispatches to `TimerProtocol` methods on each tick and on completion.

**`TimerProtocol`**
A two-method protocol decoupling the timer engine from its consumers:
- `timeRemainingOnTimer(sender:timeRemaining:)` — called every second.
- `timerHasFinished(sender:)` — called once on expiry.

### Utilities (`Utilities/`)

**`NotificationClass`**
Wraps `UNUserNotificationCenter` for scheduling and cancelling time-interval-triggered local notifications. Each instance schedules one notification in its initialiser and can cancel it via `stopNotification()`.

**`SoundManager`**
Wraps `AVAudioPlayer`. Loads `ding.mp3` from the bundle in `init()` and exposes a single `playSound()` method.

**`Utilities.swift`**
Contains:
- `formatTimeText(givenMinutes:givenSeconds:)` — formats a duration as `M:SS` or plain seconds.
- `getVerticalAllignment(amount:)` — recursive function returning the Y centre for the nth bubble.
- `washerProgrammesDatabase` / `drierProgrammesDatabase` — hardcoded cycle duration tables (in minutes).
- `constants_t` struct and the global `constants` instance — all layout, animation, colour, and debug parameters in one place.

---

## Project Structure

```
My-Laundry-Timer/
├── Prototype3/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Info.plist
│   ├── ding.mp3
│   ├── TimerManager/
│   │   ├── TimerClass.swift
│   │   └── TimerProtocol.swift
│   ├── UI/
│   │   ├── HomeViewController.swift
│   │   ├── ProgrammesViewController.swift
│   │   └── BubbleTimer.swift
│   ├── Utilities/
│   │   ├── NotificationClass.swift
│   │   ├── SoundManager.swift
│   │   └── Utilities.swift
│   ├── Base.lproj/
│   │   ├── Main.storyboard
│   │   └── LaunchScreen.storyboard
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/
│       ├── Bubble.imageset/
│       ├── Bubble_Coloured.imageset/
│       ├── Drop.imageset/
│       └── ...
├── Prototype3.xcodeproj/
├── LICENSE
└── README.md
```

---

## Requirements

| Component | Minimum version |
|---|---|
| iOS | 15.0 |
| Xcode | 13.0 |
| Swift | 5.0 |
| macOS (build host) | 12.0 (Monterey) |

No third-party dependencies. No Swift Package Manager or CocoaPods configuration.

---

## Installation

**Clone the repository**

```bash
git clone https://github.com/<your-username>/My-Laundry-Timer.git
cd My-Laundry-Timer
```

**Open in Xcode**

```bash
open Prototype3.xcodeproj
```

**Select a target and run**

1. In the Xcode toolbar, select a connected device or a simulator running iOS 15 or later.
2. Press `Cmd + R` to build and run.

No additional setup, signing configuration changes, or dependency installation is required for simulator builds. For a physical device build you will need to assign a development team in the project's Signing & Capabilities tab.

**Notification permission**

On first launch, iOS will prompt for notification permission. Grant it to enable cycle completion alerts when the app is backgrounded. The permission request is issued in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.

---

## Usage

**Starting a washer timer**

1. Tap the drop icon on the home screen to open the programme selection modal.
2. Tap **Washer**.
3. Select a wash mode: **A**, **B**, or **C**.
4. Select a temperature: **30**, **60**, **90**, **60\***, **30\***, or **Low**.
5. The modal dismisses and a new bubble timer appears on the home screen.

**Starting a dryer timer**

1. Tap the drop icon.
2. Tap **Dryer**.
3. Select a heat level: **1** through **5**.
4. The modal dismisses and a new bubble timer appears.

**Navigating back during selection**

Tap the back arrow at any point during programme selection to undo the most recent choice and return to the previous step.

**Reading an active timer**

Each bubble displays remaining time in `MM:SS` format. As time elapses the bubble shrinks. When fewer than ten minutes remain the label colour begins transitioning from black toward red, reaching full red at the one-minute mark.

**Timer completion**

When a cycle completes:
- An audio alert plays.
- If the app is backgrounded, a local notification fires.
- The bubble is removed and remaining bubbles animate into their new positions.

---

## Configuration & Tuning

All behavioural and visual parameters are centralised in `constants_t` inside `Utilities/Utilities.swift`. The most relevant ones are documented below.

| Constant | Default | Description |
|---|---|---|
| `WARP_SPEED_FACTOR` | `1` | Multiplier applied to all timer durations. Set to a value greater than 1 (e.g. `60`) during development to fast-forward cycles. |
| `DEBUG_BUBBLE_POSITION` | `false` | When `true`, draws a 4×4 red square at each bubble's computed centre point to verify layout calculations. |
| `BUBBLE_SCREEN_RATIO_START` | `0.45` | Initial bubble diameter as a fraction of screen width. |
| `BUBBLE_SCREEN_RATIO_END` | `0.25` | Final bubble diameter as a fraction of screen width. |
| `CRITICAL_TIME_U_BOUND` | `10.0` | Minutes remaining at which colour interpolation begins. |
| `CRITICAL_TIME_L_BOUND` | `1.0` | Minutes remaining at which colour interpolation ends (full critical colour). |
| `PRESENTATION_DURATION` | `5.0` | Duration in seconds of the bubble entry spring animation. |
| `SPRING_DAMPING` | `0.75` | Spring damping for bubbles 3 and beyond. |
| `CEILING_SPRING_DAMPING` | `0.80` | Spring damping for the first two bubbles. |

---

## Laundry Programme Databases

Cycle durations are hardcoded in `Utilities/Utilities.swift` as two global arrays. Times are in minutes.

**Washer** — indexed as `washerProgrammesDatabase[mode][temperature]`

| Mode \ Temp | 30 | 60 | 90 | 60\* | 30\* | Low |
|---|---|---|---|---|---|---|
| A | 40 | 40 | 40 | 36 | 34 | 34 |
| B | 40 | 40 | 40 | 36 | 34 | 34 |
| C | 40 | 40 | 40 | 36 | 34 | 34 |

**Dryer** — indexed as `drierProgrammesDatabase[heatLevel]`

| Level 1 | Level 2 | Level 3 | Level 4 | Level 5 |
|---|---|---|---|---|
| 50 min | 50 min | 50 min | 50 min | 33 min |

To add or change cycle durations, edit these two arrays directly. No other code changes are required.

---

## Known Limitations & Future Work

- **Hardcoded programme times.** Durations are not editable by the user and do not correspond to any specific appliance model. They should be made configurable or sourced from a user-managed database.
- **State is not persisted.** Active timers are held in memory only. Killing and relaunching the app loses all running timers (though notifications already scheduled will still fire).
- **Bubble pop animation is a stub.** The completion block in `BubbleTimer.timerHasFinished` contains a commented placeholder for a pop animation. The bubble is removed without any visual transition.
- **`HomeViewController.reference` is a static singleton.** This works for the current single-screen architecture but would need to be replaced with a proper delegate or closure if the navigation hierarchy becomes more complex.
- **No unit or UI tests.** The `Prototype3.xcodeproj` ships with no test targets.
- **Xcode project name.** The Xcode scheme and bundle are named `Prototype3`, a remnant of the prototyping phase. This should be renamed to match the repository and product name before any App Store submission.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for the full text.
