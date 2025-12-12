# 📱 iOS Notification Testing Guide

## ⚠️ IMPORTANT: iOS Foreground Notification Behavior

**iOS WILL NOT show notification banners when your app is in the FOREGROUND** (app is open and active on screen).

This is Apple's default behavior - notifications only appear as banners when:
- The app is in the **background** (home screen, other app open)
- The device is **locked**

## 🧪 How to Properly Test Notifications on iPhone

### Test 1: Background Notification (Recommended)

1. **Run the app** on your iPhone
2. **Tap the bell icon** (🔔) in top-right
3. **Tap "SHOW NOTIFICATION NOW"** button
4. **Immediately press the HOME button** (or swipe up)
   - This backgrounds the app
5. **Wait 1-2 seconds**
6. **Look for the notification banner** at the top of your screen!

✅ **Expected**: You should see a banner notification with:
- Title: "🎉 Success!"
- Body: "Your notification system is working perfectly!"

---

### Test 2: Lock Screen Notification

1. **Run the app** on your iPhone
2. **Tap the bell icon** and then "SHOW NOTIFICATION NOW"
3. **Lock your iPhone** (press power button)
4. **The notification should appear on lock screen**

✅ **Expected**: Notification appears on lock screen

---

### Test 3: Check Notification Center

Even if the app is in foreground, the notification is still sent - it just goes to Notification Center instead of showing a banner.

1. **Run the app**
2. **Tap "SHOW NOTIFICATION NOW"**
3. **Swipe down from top** to open Notification Center
4. **Look for the notification** in the list

✅ **Expected**: Notification appears in Notification Center

---

## 🔍 Debugging Steps

### Step 1: Check Console Logs

Look for these messages in order:

```
🧪 Testing immediate notification...
🔍 Checking notification permissions...
✅ Permissions OK, showing notification...
✅ Immediate test notification sent successfully!
✅ Test complete - You should see a notification now!
```

### Step 2: Verify Permissions

If you see:
```
❌ Notification permissions not granted!
```

Then:
1. Open **Settings** on iPhone
2. Scroll to **Notifications**
3. Find **"Food Tracking"**
4. Enable ALL notification options:
   - ✅ Allow Notifications
   - ✅ Lock Screen
   - ✅ Notification Center
   - ✅ Banners
   - ✅ Sounds
   - ✅ Badges

### Step 3: Restart App

After changing permissions:
1. **Force close** the app (swipe up in app switcher)
2. **Reopen** the app
3. **Try the test again**

---

## 💡 Solution: Enable Foreground Notifications

If you want notifications to show EVEN when app is in foreground, we need to add a foreground notification handler.

**Would you like me to implement this?** It requires:
1. Adding iOS native code to handle foreground notifications
2. Updating the notification service

This will allow banners to appear even when the app is open!

---

## ✅ Quick Checklist

Before reporting an issue, verify:

- [ ] I tested with app in **BACKGROUND** (not foreground)
- [ ] I checked **Notification Center** (swipe down)
- [ ] I enabled **ALL notification permissions** in Settings
- [ ] I see "✅ Immediate test notification sent successfully!" in console
- [ ] I **restarted the app** after changing permissions
- [ ] My iPhone is **not in Do Not Disturb mode**

---

## 🎯 Expected Behavior Summary

| App State | Notification Behavior |
|-----------|----------------------|
| **Foreground** (app open) | ❌ No banner (iOS default)<br>✅ Goes to Notification Center |
| **Background** (home screen) | ✅ Shows banner at top |
| **Locked** | ✅ Shows on lock screen |

---

## 🚀 Next Steps

1. Try **Test 1** (Background Notification) above
2. If it works → Notifications are working correctly! 🎉
3. If it doesn't work → Share the console logs and I'll help debug

The key is: **Press HOME button immediately after tapping the test button!**
