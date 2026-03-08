# 🚀 Simple Upload Guide - Supabase Storage (FREE)

## ✅ Best Free Option: Supabase Storage

**Why?** You're already using Supabase, so it's the easiest and most integrated option!

**Free Tier:**
- ✅ 1 GB storage (enough for ~30 audio files)
- ✅ 2 GB bandwidth/month
- ✅ No credit card needed
- ✅ Fast CDN

---

## 📤 3 Simple Steps (5 minutes)

### Step 1: Create Bucket
1. Go to: **https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/storage/buckets**
2. Click **"New bucket"**
3. Name: `avdhan`
4. ✅ Check **"Public bucket"**
5. Click **"Create bucket"**

### Step 2: Upload File
1. Click on the `avdhan` bucket
2. Click **"Upload file"**
3. Select your file (MP3 recommended):
   ```
   C:\Users\DhaneshMadhukarMengi\Downloads\mykhanaji-avdhan.mp3
   ```
4. Wait for upload (32.52 MB - takes ~30 seconds)

### Step 3: Get URL & Update Database
1. Click on the uploaded file
2. Copy the **Public URL**
3. Update database:

**Option A: Via Supabase SQL Editor**
- Go to: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/sql/new
- Run:
```sql
UPDATE avdhan 
SET audio_url = 'YOUR_COPIED_URL_HERE'
WHERE id = 'ae0c49c7-c295-4c69-8fd1-2c77a7b3b855';
```

**Option B: I'll do it for you**
- Just paste the URL here and I'll update it!

---

## 🎯 Direct Links

- **Storage**: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/storage/buckets
- **SQL Editor**: https://supabase.com/dashboard/project/odzpwqclczerzxpkcsnx/sql/new

---

## ✅ That's It!

Once you upload and update the URL, the audio will be available in your app! 🎉

---

## 📊 Storage Info

- **Your file**: 32.52 MB
- **Free tier**: 1,024 MB
- **Remaining**: ~991 MB (plenty of space!)

**This is completely FREE and perfect for your needs!** ✅

