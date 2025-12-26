# App Icon Setup

## To change your app icon:

1. **Prepare your icon image:**
   - Create a 1024x1024 PNG image for your app icon
   - Save it as `assets/icon/app_icon.png`
   - Make sure it's a square image with no transparency for best results

2. **Update colors in pubspec.yaml:**
   - Replace `#hexcode` with your brand colors (e.g., `#FF0000` for red)

3. **Generate icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Current icon locations:**
   - Android: `android/app/src/main/res/mipmap-*/launcher_icon.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Web: `web/icons/`

## Tips:
- Use simple, bold designs that work at small sizes
- Avoid text in the icon (hard to read when small)
- Test on both light and dark backgrounds
- Consider your brand colors and app theme

Place your 1024x1024 PNG icon at `assets/icon/app_icon.png` and run the commands above!
