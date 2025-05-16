# Assets Directory

This directory contains all static assets for the WooCommerce Flutter application.

## Asset Organization

```
assets/
├── images/              # App images and icons
│   ├── app_icon.png     # App launcher icon
│   ├── splash/          # Splash screen assets
│   └── placeholders/    # Placeholder images
├── fonts/               # Custom fonts
└── translations/        # Localization files
```

## Required Assets

### 1. App Icon
- **Filename**: `images/app_icon.png`
- **Format**: PNG with transparency
- **Size**: 1024x1024px (minimum)
- **Background**: Should work on both light and dark themes

### 2. Splash Screen
- **Filename**: `images/splash/splash.png`
- **Format**: PNG or JPG
- **Size**: 1242x2208px (portrait)
- **Notes**: 
  - Keep important content within the safe area
  - Consider light and dark theme variants

### 3. Placeholder Images
- **Location**: `images/placeholders/`
- **Formats**: PNG or WebP
- **Sizes**:
  - Product thumbnails: 300x300px
  - Banners: 1200x600px
  - Category icons: 200x200px

## Adding New Assets
1. Place files in the appropriate subdirectory
2. Update `pubspec.yaml` if adding new directories
3. Optimize images using tools like `flutter_native_splash` or `flutter_launcher_icons`
4. Run `flutter pub run flutter_launcher_icons` to regenerate icons

## Best Practices
- Use vector graphics (SVG) when possible
- Optimize image sizes for mobile
- Follow platform-specific guidelines for icons
- Maintain aspect ratios for consistent display
- Consider using `cached_network_image` for remote assets