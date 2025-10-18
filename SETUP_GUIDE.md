# Smart Toy Store System - Setup Guide

## Quick Start Guide

This guide will help you set up the complete Smart Toy Store System from scratch.

## Prerequisites Checklist

- [ ] Flutter SDK 3.x installed
- [ ] Dart SDK 3.0+ installed
- [ ] Android Studio or VS Code with Flutter extension
- [ ] Arduino IDE with ESP8266/ESP32 support
- [ ] WiFi hotspot capability
- [ ] Network configuration access

## Step 1: Network Setup

### Create WiFi Hotspot

1. **Create a WiFi hotspot with these exact settings:**
   - SSID: `db`
   - Password: `123456789`
   - Band: 2.4 GHz (required for ESP8266/ESP32)

2. **Set your laptop/server IP to:**
   - IP Address: `10.40.190.130`
   - Subnet: `255.255.255.0`

### Verify Network

```bash
# On Windows
ipconfig

# On Mac/Linux
ifconfig
```

Look for your hotspot connection and verify the IP is `10.40.190.130`.

## Step 2: Backend Server Setup

### Install Dependencies

```bash
cd backend
dart pub get
```

### Start the Server

```bash
dart run bin/server.dart
```

You should see:
```
Database initialized
Server running on http://10.40.190.130:8080
WebSocket endpoint: ws://10.40.190.130:8080/ws
```

### Test Backend

Open a new terminal and test:

```bash
curl http://10.40.190.130:8080/orders
```

## Step 3: Flutter App Setup

### Install Dependencies

```bash
cd project
flutter pub get
```

### Generate Code

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Connect Android Device

1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect via USB
4. Verify connection:

```bash
flutter devices
```

### Run the App

```bash
flutter run
```

### First Time Login

1. Tap "Sign up" on the login screen
2. Create an account with:
   - Username: test
   - Email: test@example.com
   - Department: Toy Guns
   - Password: test123

## Step 4: Arduino Setup

### Install Libraries

In Arduino IDE, go to **Tools → Manage Libraries** and install:

1. **ESP8266WiFi** (for ESP8266 boards)
2. **ESP8266HTTPClient**
3. **ArduinoJson** (version 6.x)

### Configure Board

1. Go to **Tools → Board → Boards Manager**
2. Search and install "ESP8266" or "ESP32"
3. Select your board under **Tools → Board**

### Upload Code

1. Open `arduino/smart_toy_rfid.ino`
2. Select correct COM port under **Tools → Port**
3. Click Upload button

### Test Arduino

1. Open Serial Monitor (115200 baud)
2. You should see:
```
Smart Toy Store - RFID System
Connecting to WiFi...
WiFi Connected!
IP Address: 10.40.X.X
System Ready - Waiting for RFID scans...
```

### Simulate RFID Scan

In Serial Monitor, type one of these UIDs and press Enter:
- `A12B3C` (Toy Guns - Red LED)
- `D44F8Z` (Action Figures - Green LED)
- `E77K9L` (Dolls - Blue LED)

## Step 5: Dashboard Setup

### Open Dashboard

1. Navigate to `dashboard/index.html`
2. Open with any modern web browser
3. You should see "Connected" status in top-right

### Verify Connection

Check browser console (F12):
- Look for "WebSocket connected" message
- No error messages should appear

## Step 6: System Integration Test

### Test Complete Flow

1. **Create Order (Mobile App):**
   - Open Flutter app
   - Login with your credentials
   - Note: Order creation UI is in home screen

2. **Simulate RFID Scan (Arduino):**
   - Open Arduino Serial Monitor
   - Enter RFID UID: `A12B3C`
   - Press Enter

3. **Watch Real-time Updates:**
   - Arduino Serial Monitor shows status changes
   - LED blinks during PROCESSING and ON_THE_WAY
   - Mobile app updates automatically
   - Dashboard shows live order status

### Expected Flow

```
Initial:    PENDING (no LED)
After 0s:   PROCESSING (LED blinking)
After 10s:  ON_THE_WAY (LED blinking)
After 20s:  DELIVERED (LED solid)
After 30s:  Complete (LED off, reset)
```

## Troubleshooting

### Issue: Backend won't start

**Solution:**
```bash
# Check if port is already in use
# Windows
netstat -ano | findstr :8080

# Mac/Linux
lsof -i :8080

# Kill the process if needed
```

### Issue: Flutter app can't connect

**Symptoms:** Login fails, orders don't load

**Solution:**
1. Verify backend is running
2. Check mobile device is on "db" WiFi
3. Ping backend from mobile:
   - Download network testing app
   - Ping 10.40.190.130

### Issue: Arduino won't connect to WiFi

**Symptoms:** "WiFi Connection Failed!" in Serial Monitor

**Solution:**
1. Verify WiFi credentials in code
2. Ensure hotspot is 2.4 GHz (not 5 GHz)
3. Check ESP8266/ESP32 is powered properly
4. Try WiFi.begin(ssid, password) with delay(10000)

### Issue: Dashboard shows "Disconnected"

**Solution:**
1. Open browser console (F12)
2. Check for WebSocket errors
3. Verify backend WebSocket is running
4. Try refreshing the page

### Issue: Orders not updating in real-time

**Solution:**
1. Check WebSocket connection status in all clients
2. Restart backend server
3. Reconnect mobile app
4. Refresh dashboard

## Testing Scenarios

### Scenario 1: Single Order Complete Flow

1. Create order in mobile app
2. Scan RFID in Arduino
3. Watch status updates across all devices
4. Verify DELIVERED status appears everywhere
5. Check Arduino LED turns off after completion

### Scenario 2: Multiple Concurrent Orders

1. Create 3 orders with different RFID UIDs
2. Scan first RFID
3. Before it completes, scan second RFID
4. Verify both update independently
5. Check dashboard shows both orders

### Scenario 3: Offline Recovery

1. Disconnect mobile device from WiFi
2. Note: Orders are cached
3. Reconnect to WiFi
4. App should sync automatically

## Production Deployment

### Security Considerations

1. **Change JWT Secret Key:**
   - Edit `backend/lib/auth.dart`
   - Update `secretKey` constant

2. **Secure WiFi:**
   - Use WPA2 encryption
   - Change default password

3. **Restrict IP Access:**
   - Configure firewall rules
   - Limit backend access to local network

### Performance Optimization

1. **Backend:**
   - Consider using real database (PostgreSQL, MongoDB)
   - Add connection pooling
   - Implement rate limiting

2. **Mobile App:**
   - Enable Hive encryption
   - Optimize image loading
   - Implement pagination for large order lists

3. **Arduino:**
   - Add RFID reader hardware
   - Implement error retry logic
   - Add LED brightness control

## Next Steps

### Enhancements to Consider

1. **User Management:**
   - Add admin panel
   - Role-based access control
   - User activity logs

2. **Analytics:**
   - Order completion time tracking
   - Department performance metrics
   - Revenue trends

3. **Notifications:**
   - Push notifications for mobile
   - Email alerts for admins
   - SMS for critical updates

4. **Hardware:**
   - Integrate real RFID readers
   - Add barcode scanner support
   - Display screen for status

## Support

For issues or questions:
1. Check the logs (backend console, Arduino Serial Monitor)
2. Verify network connectivity
3. Review this guide for common issues
4. Check README.md for API documentation

## System Monitoring

### Health Check Endpoints

Add these to backend for monitoring:

```dart
router.get('/health', (Request request) {
  return Response.ok(jsonEncode({
    'status': 'healthy',
    'timestamp': DateTime.now().toIso8601String(),
    'websocket_clients': _clients.length,
  }));
});
```

### Mobile App Logs

Enable debug logging in Flutter:

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug log: $message');
}
```

### Arduino Debug Mode

Add verbose logging in Arduino code:

```cpp
#define DEBUG_MODE true

#if DEBUG_MODE
  Serial.println("Debug: Sending HTTP request...");
#endif
```

## Conclusion

You now have a fully functional Smart Toy Store System running on your local network. All components should be communicating in real-time, and you can track orders from creation through delivery across all platforms.

Happy tracking!
