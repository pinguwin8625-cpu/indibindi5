# Mock User Profile Photos Setup

## Required Images

Place the following 6 profile photos in the `assets/images/` folder:

### 1. profile_admin.jpg
- **User:** Admin User
- **Suggested:** Professional business person or generic admin avatar
- **Dimensions:** 400x400px minimum (square)

### 2. profile_ahmet.jpg
- **User:** Ahmet Yılmaz (Turkish male driver)
- **Age:** 30-40
- **Suggested:** Middle Eastern/Turkish man, friendly expression
- **Dimensions:** 400x400px minimum (square)

### 3. profile_sarah.jpg
- **User:** Sarah Johnson (American female driver)
- **Age:** 25-35
- **Suggested:** Caucasian woman, professional, smiling
- **Dimensions:** 400x400px minimum (square)

### 4. profile_elena.jpg
- **User:** Elena García (Spanish female rider)
- **Age:** 20-30
- **Suggested:** Hispanic/European woman, casual, friendly
- **Dimensions:** 400x400px minimum (square)

### 5. profile_mohammed.jpg
- **User:** Mohammed Al-Rahman (Arab male driver)
- **Age:** 35-45
- **Suggested:** Arab/Middle Eastern man, professional
- **Dimensions:** 400x400px minimum (square)

### 6. profile_yuki.jpg
- **User:** Yuki Tanaka (Japanese female rider)
- **Age:** 20-30
- **Suggested:** Asian (Japanese) woman, casual, student-like
- **Dimensions:** 400x400px minimum (square)

## Where to Get Mock Photos

### Free Stock Photo Sites (Royalty-Free for Commercial Use):
1. **Unsplash** - https://unsplash.com/s/photos/portrait
2. **Pexels** - https://www.pexels.com/search/portrait/
3. **Pixabay** - https://pixabay.com/photos/search/portrait/

### AI-Generated Photos (No Copyright Issues):
1. **This Person Does Not Exist** - https://thispersondoesnotexist.com/
   - Generate unique faces that don't belong to real people
   - Download 6 different faces
   - Rename according to the list above

2. **Generated Photos** - https://generated.photos/
   - Create realistic AI portraits
   - Filter by age, ethnicity, emotion

### Search Tips:
- Use keywords: "professional portrait", "friendly person", "driver portrait"
- Ensure commercial use is allowed
- Choose diverse, friendly, professional-looking people
- Crop to square format (1:1 ratio)
- Optimize file size (keep under 500KB each)

## Image Specifications

- **Format:** JPG (or PNG)
- **Size:** 400x400px to 1000x1000px
- **Aspect Ratio:** 1:1 (square)
- **File Size:** < 500KB per image (for app performance)
- **Quality:** High quality, clear face, good lighting

## How to Add Images

1. Download 6 suitable portrait photos
2. Rename them exactly as listed above:
   - profile_admin.jpg
   - profile_ahmet.jpg
   - profile_sarah.jpg
   - profile_elena.jpg
   - profile_mohammed.jpg
   - profile_yuki.jpg

3. Place them in: `/assets/images/`

4. Run the app - profile photos will appear automatically!

## Optimization (Optional)

To optimize images for mobile:
```bash
# Using ImageMagick (install via brew)
brew install imagemagick

# Resize and compress
mogrify -resize 800x800 -quality 85 assets/images/profile_*.jpg
```

## Quick AI-Generated Method (Recommended)

1. Visit https://thispersondoesnotexist.com/
2. Refresh the page 6 times
3. Right-click and "Save Image As" each time
4. Rename files as listed above
5. Move to `assets/images/`
6. Done! ✅

---

**Note:** These are temporary mock photos for testing. Replace with real user photos when implementing proper backend with user uploads.
