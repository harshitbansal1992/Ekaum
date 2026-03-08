# 📻 Add Avdhan Audio - Instructions

## File Information
- **File Path**: `C:\Users\DhaneshMadhukarMengi\Downloads\mykhanaji-avdhan.mp3`
- **Supabase URL**: `https://odzpwqclczerzxpkcsnx.supabase.co/storage/v1/object/public/avdhan/mykhanaji-avdhan.mp3`
- **Title**: महबरहम मयखन अवधन यग - रजन 10 मनट कर
- **Description**: सतगर वण - शसतर क बत
- **Duration**: ~10 minutes (600 seconds)

---

## ⚠️ Important: File Upload Required

The audio file is currently on your local computer. To add it to Avdhan, you need to:

1. **Upload the file to cloud storage** (Firebase Storage, AWS S3, or any public URL)
2. **Get the public URL** of the uploaded file
3. **Add it to the database** using the admin API

---

## 🚀 Quick Steps

### Option 1: Use the PowerShell Script

1. **Upload the file first** to a cloud storage service
2. **Run the script**:
   ```powershell
   .\add_avdhan_audio.ps1 -AudioUrl "https://your-storage-url.com/audio.mp4"
   ```

### Option 2: Manual API Call

1. **Get admin JWT token** (login first):
   ```bash
   curl -X POST http://localhost:3000/api/auth/login \
     -H "Content-Type: application/json" \
     -d "{\"email\":\"test@bslnd.com\",\"password\":\"Test123456\"}"
   ```

2. **Add audio** (replace `YOUR_TOKEN` and `AUDIO_URL`):
   ```bash
   curl -X POST http://localhost:3000/api/admin/avdhan \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d "{
       \"title\": \"महबरहम मयखन अवधन यग - रजन 10 मनट कर\",
       \"description\": \"सतगर वण - शसतर क बत\",
       \"audioUrl\": \"AUDIO_URL\",
       \"duration\": 600
     }"
   ```

---

## 📤 Upload Options

### Firebase Storage (Recommended)
1. Go to Firebase Console → Storage
2. Upload the MP4 file
3. Get the public URL
4. Use that URL in the API call

### AWS S3
1. Upload to S3 bucket
2. Make it public
3. Get the public URL
4. Use that URL in the API call

### Other Options
- Google Drive (make public, get shareable link)
- Dropbox (make public, get direct link)
- Any CDN or file hosting service

---

## 📋 Database Schema

The audio will be stored in the `avdhan` table with:
- `title`: Audio title
- `description`: Audio description
- `audio_url`: Public URL to the audio file
- `thumbnail_url`: (Optional) Thumbnail image URL
- `duration`: Duration in seconds (600 = 10 minutes)

---

## ✅ After Adding

Once added, the audio will:
- ✅ Appear in the Avdhan list in the app
- ✅ Be playable for subscribed users
- ✅ Show preview for non-subscribed users

---

## 🔧 Troubleshooting

### "Audio file not found"
- Check the file path is correct
- Make sure the file exists

### "Audio URL is required"
- You must upload the file to cloud storage first
- Get the public URL before adding to database

### "Invalid or expired token"
- Login again to get a fresh token
- Make sure you're using an admin account

---

## 📝 Notes

- The file is an MP4 video file, but it can be used as audio
- Duration is set to 600 seconds (10 minutes) - adjust if needed
- Thumbnail is optional - you can add it later

