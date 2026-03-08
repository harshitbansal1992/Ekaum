# 🔧 Avdhan Audio Playback Troubleshooting Guide

## ✅ Quick Checks

### 1. Verify File is Accessible
Test the audio URL directly in your browser:
```
https://odzpwqclczerzxpkcsnx.supabase.co/storage/v1/object/public/avdhan/mykhanaji-avdhan.mp3
```

**Expected Result:**
- ✅ File should download or play in browser
- ❌ If you get 404 or access denied, the file isn't accessible

### 2. Check Supabase Storage Bucket Settings

1. Go to: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/storage/buckets
2. Click on the `avdhan` bucket
3. Verify:
   - ✅ Bucket is **Public** (not private)
   - ✅ File `mykhanaji-avdhan.mp3` exists in the bucket
   - ✅ File size matches your local file

### 3. Check Storage Policies (RLS)

Supabase Storage uses Row Level Security. For public access, you need a policy:

**Check existing policies:**
1. Go to: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/storage/policies
2. Look for policies on `storage.objects` table
3. Should have a policy allowing public SELECT access

**✅ Policy Status:** The storage policy has been created and verified.

**If you need to recreate it:**
```sql
-- Drop and recreate policy for public read access to avdhan bucket
DROP POLICY IF EXISTS "Allow public read access to avdhan bucket" ON storage.objects;

CREATE POLICY "Allow public read access to avdhan bucket"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avdhan');
```

**Or via Supabase Dashboard:**
1. Go to Storage → Policies
2. Click "New Policy"
3. Select "For full customization"
4. Policy name: "Allow public read access to avdhan bucket"
5. Allowed operation: SELECT
6. Target roles: public
7. USING expression: `bucket_id = 'avdhan'`

### 4. Verify Database URL

**✅ Verified:** The database URL is correct.

Current configuration:
- **ID**: `ae0c49c7-c295-4c69-8fd1-2c77a7b3b855`
- **Title**: महबरहम मयखन अवधन यग - रजन 10 मनट कर
- **Audio URL**: `https://odzpwqclczerzxpkcsnx.supabase.co/storage/v1/object/public/avdhan/mykhanaji-avdhan.mp3`
- **Duration**: 600 seconds (10 minutes)

To verify yourself:
```sql
SELECT id, title, audio_url, duration FROM avdhan 
WHERE id = 'ae0c49c7-c295-4c69-8fd1-2c77a7b3b855';
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Error loading audio" / Network Error

**Possible Causes:**
- No internet connection
- File doesn't exist at the URL
- CORS issues

**Solutions:**
1. Check internet connection
2. Test URL in browser
3. Verify file exists in Supabase Storage
4. Check storage policies are set correctly

### Issue 2: Audio URL returns 404

**Solution:**
1. Verify file name matches exactly: `mykhanaji-avdhan.mp3`
2. Check file is in the `avdhan` bucket
3. Re-upload the file if needed

### Issue 3: Audio loads but doesn't play

**Possible Causes:**
- MP4 codec not supported by `just_audio`
- File is corrupted
- Duration is zero

**Solutions:**
1. Try converting MP4 to MP3:
   ```bash
   ffmpeg -i input.mp4 -vn -acodec libmp3lame mykhanaji-avdhan.mp3
   ```
2. Upload MP3 version to Supabase
3. Update database with new URL

### Issue 4: CORS Error

**Solution:**
Supabase Storage should handle CORS automatically for public buckets. If you see CORS errors:

1. Verify bucket is set to **Public**
2. Check storage policies allow public access
3. Try accessing the URL directly in browser (should work)

### Issue 5: "Preview Limit Reached" immediately

**Solution:**
This means the audio is playing but hitting the 2-minute preview limit. If you have a subscription:
1. Check subscription status in the app
2. Verify subscription is active in database
3. Check subscription provider is working correctly

---

## 🔍 Debugging Steps

### Step 1: Check App Logs
When you click play, check the console/logs for:
- `Loading audio from: [URL]`
- Any error messages
- Network request status

### Step 2: Test URL Directly
Open the audio URL in:
- Browser (should download/play)
- Postman/curl (should return file)
- Mobile browser (should work)

### Step 3: Verify File Format
MP4 files can have different codecs. Check:
```bash
ffprobe mykhanaji-avdhan.mp3
```

**Recommended formats for `just_audio`:**
- MP3 (most compatible)
- AAC (good compatibility)
- M4A (good compatibility)
- MP4 with AAC audio (may work)

### Step 4: Test with Different File
Try uploading a small test MP3 file to verify the setup works:
1. Upload test file to Supabase Storage
2. Update database with test URL
3. Try playing in app

---

## ✅ Verification Checklist

- [x] **Storage policy created** - "Allow public read access to avdhan bucket" policy exists
- [x] **Database URL verified** - Correct URL stored in database
- [ ] File exists in Supabase Storage bucket `avdhan`
- [ ] Bucket is set to **Public**
- [ ] URL works when opened in browser (test the URL directly)
- [ ] File format is compatible (MP3 recommended for better compatibility)
- [ ] Internet connection is active
- [ ] App has network permissions (Android/iOS)
- [ ] Error handling improved in audio player (✅ Done)

---

## 🚀 Quick Fix: Re-upload File

If nothing works, try re-uploading:

1. **Via Supabase Dashboard:**
   - Go to Storage → avdhan bucket
   - Delete old file (if exists)
   - Upload `mykhanaji-avdhan.mp3`
   - Copy public URL
   - Update database

2. **Via PowerShell Script:**
   ```powershell
   .\upload_to_supabase_storage.ps1 -SupabaseKey "YOUR_KEY"
   ```

3. **Update Database:**
   ```sql
   UPDATE avdhan 
   SET audio_url = 'https://odzpwqclczerzxpkcsnx.supabase.co/storage/v1/object/public/avdhan/mykhanaji-avdhan.mp3'
   WHERE id = 'ae0c49c7-c295-4c69-8fd1-2c77a7b3b855';
   ```

---

## 📞 Still Not Working?

If the issue persists:
1. Check the exact error message in the app
2. Check console logs for detailed errors
3. Verify all checklist items above
4. Try with a different audio file format (MP3)
5. Test on a different device/emulator

The improved error handling in the app will now show specific error messages to help identify the exact issue.

