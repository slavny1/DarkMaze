# DarkMaze TestFlight preparation

Branch: `release/testflight-candidate-20261112`
App bundle ID: `slavny1.DarkMaze`
Current project version: 1.1 (build 1). Check the corresponding App Store Connect version, and increase build number on future uploads.

## TestFlight beta description (English)

DarkMaze is an accessible sound-and-haptics maze game. Guide a ball through winding corridors using a virtual joystick. Explore the tutorial, adjust visibility, and find the finish.

## What to Test (English)

1. Finish all four tutorial stages using only the joystick.
2. Try every level from 5×5 to 11×11 and regenerate maps several times.
3. Verify gentle wall vibrations start before collision and intensify near a wall.
4. Verify the ball resets only when its centre enters a black wall cell.
5. Verify the ball wins as soon as its edge reaches the finish tile.
6. Verify hidden maze, hidden ball and hidden finish do not change game physics.
7. Use VoiceOver and report whether the joystick and its four directional actions are discoverable.
8. Check headphones, speaker, silent mode, interrupted audio and app switching.
9. Report unexpected freezes, missing sounds, crashes or navigation blockers.

## Что тестировать (ru-RU)

Пройди четыре этапа обучения и все семь уровней. Проверь движение джойстиком, раннюю вибрацию возле стен, столкновения по центру шарика и финиш при касании квадрата. Попробуй скрыть лабиринт, шарик и финиш. Проверь VoiceOver, звук в наушниках, работу после сворачивания игры и входящего звонка. Отправляй замечания и скриншоты через TestFlight.

## Local build / upload checklist

1. On a Mac, use Xcode 26 or newer with the required iOS SDK.
2. `git fetch origin && git switch --track origin/release/testflight-candidate-20261112` (or switch existing local branch).
3. `bash scripts/test-maze.sh`
4. `xcodebuild -project DarkMaze.xcodeproj -scheme DarkMaze -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
5. In Xcode, select **Any iOS Device (arm64)**, **Product → Archive**.
6. Open **Window → Organizer → Archives**, select the archive, **Distribute App → App Store Connect → Upload** and follow signing/export prompts.
7. In App Store Connect → TestFlight, finish export compliance questions, add beta description and What to Test, then assign the build to an internal testing group.
8. For external users, create an external group and submit the first beta build for Beta App Review as prompted.
9. Do not submit for public App Store Review until the release-candidate build and accessibility flows have been tested by people.

**Not done automatically:** Apple signing, archive, submission, real device testing, App Store Connect configuration.

## Regression checks before TestFlight

- No direct ball drag, only joystick movement
- Joystick returns to neutral, movement sound stops there
- Wall haptics gradually increase and collision returns to start
- Goal tile touched by ball edge triggers win
- Visibility controls remain above the maze
- No Reset button in the tutorial
- New generated levels obey >2N, connectivity, no 2×2 rooms, no four-cell runs
- No crashes or unexpected joystick motion on app resume

Keep beta feedback in GitHub issues or the App Store Connect TestFlight feedback tab.
