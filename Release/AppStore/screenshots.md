# DarkMaze screenshots: real app captures

Keep the existing `DarkMaze/Assets.xcassets/AppIcon.appiconset` unchanged.

The final App Store screenshots must show **the actual UI from the compiled release-candidate app**. Do not create fictional screens or imply that features exist when they do not.

## Screenshot shot list

1. **Explore by sound** — show a regular maze and joystick, all elements visible.
2. **Feel the walls** — ball close to a wall, with visibility toggles visible. Add an editorial caption about sound and haptics only if the real screenshot remains recognisable.
3. **Play in the dark** — maze hidden, ball visible, finish visible.
4. **Make it harder** — hide maze, ball and finish; the joystick and visibility buttons remain visible.
5. **Learn step by step** — tutorial stage 1 or 2 with its title visible.
6. **Find your way** — a more complex, naturally generated level.

### Screenshot capture on Mac

1. Choose an iPhone simulator in Xcode, run the *release-candidate* branch.
2. Show each screen in a clean representative state. Hide debug overlays.
3. Simulator menu: **File → Save Screenshot** (or use `xcrun simctl io booted screenshot filename.png`).
4. For App Store Connect, provide up to 10 screenshots per device. At least one relevant current iPhone size is required.
5. Prefer a large iPhone simulator accepted by App Store Connect: e.g., supported 6.9-inch output 1320×2868 or 1290×2796; use the exact accepted size in Apple's screenshot specifications for the device selected.
6. Leave screenshot dimensions intact; do not fake UI or stretch the image.
7. If useful, use the same original captures to create captions/graphic compositions for English and Russian locales.

### Proposed English captions

- A MAZE YOU CAN FEEL
- LISTEN TO THE WALLS
- PLAY WITHOUT SEEING
- CHOOSE YOUR CHALLENGE
- LEARN ONE STEP AT A TIME

### Russian captions

- ЛАБИРИНТ НА ОЩУПЬ
- СЛУШАЙ СТЕНЫ
- ИГРАЙ БЕЗ ЗРЕНИЯ
- ВЫБИРАЙ СЛОЖНОСТЬ
- УЧИСЬ ШАГ ЗА ШАГОМ

These are creative captions; actual screenshot art and dimensions must be verified against a real simulator capture.
