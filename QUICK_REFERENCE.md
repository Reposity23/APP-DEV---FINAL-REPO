# Smart Toy Store System - Quick Reference Card

## Network Settings
```
WiFi SSID:     db
Password:      123456789
Server IP:     10.40.190.130
Server Port:   8080
```

## URLs
```
Backend API:   http://10.40.190.130:8080
WebSocket:     ws://10.40.190.130:8080/ws
Dashboard:     file:///path/to/dashboard/index.html
```

## Quick Commands

### Start Backend Server
```bash
# Linux/Mac
cd backend && ./start_server.sh

# Windows
cd backend && start_server.bat

# Manual
cd backend && dart run bin/server.dart
```

### Run Flutter App
```bash
flutter pub get
flutter run
```

### Arduino Serial Monitor
```
Baud Rate: 115200
Test RFID:
  - Type: A12B3C
  - Press: Enter
```

## RFID Test UIDs
```
A12B3C → Toy Guns       → Red LED
D44F8Z → Action Figures → Green LED
E77K9L → Dolls          → Blue LED
F23M1N → Puzzles        → Red LED
G56P2Q → Board Games    → Green LED
```

## Order Status Flow
```
PENDING (0s)
   ↓
PROCESSING (blinking LED)
   ↓ (10s)
ON_THE_WAY (blinking LED)
   ↓ (10s)
DELIVERED (solid LED)
   ↓ (10s)
RESET
```

## Default Test Account
```
Username:   test
Email:      test@example.com
Password:   test123
Department: Toy Guns
```

## API Endpoints
```
POST /login        - User login
POST /signup       - User registration
GET  /orders       - Get all orders (auth required)
POST /orders       - Create order (auth required)
POST /updateStatus - Update from Arduino
GET  /ws          - WebSocket connection
```

## Common Issues & Fixes

### Backend Won't Start
```bash
# Check port
lsof -i :8080           # Mac/Linux
netstat -ano | find "8080"  # Windows

# Kill process if needed
kill -9 <PID>           # Mac/Linux
taskkill /PID <PID> /F  # Windows
```

### Flutter Can't Connect
```bash
# Verify backend running
curl http://10.40.190.130:8080/orders

# Check device WiFi
# Settings → WiFi → Connected to "db"
```

### Arduino WiFi Failed
```
1. Check SSID/password in code
2. Ensure 2.4 GHz (not 5 GHz)
3. Press RESET button
4. Check Serial Monitor
```

### Dashboard Not Updating
```
1. F12 → Console
2. Look for "WebSocket connected"
3. Refresh page (Ctrl+R / Cmd+R)
4. Verify backend running
```

## File Locations

### Flutter App
```
lib/main.dart              - Entry point
lib/services/auth_service.dart  - Change API URL here
lib/providers/app_provider.dart - State management
```

### Backend
```
backend/bin/server.dart    - Main server
backend/lib/database.dart  - Storage logic
backend/data/              - Database files
```

### Arduino
```
arduino/smart_toy_rfid.ino - Firmware
Line 4-6:                  - WiFi credentials
Line 7-8:                  - Server IP/Port
```

### Dashboard
```
dashboard/index.html       - Complete dashboard
Line 241:                  - WebSocket URL
```

## Configuration Changes

### Change Server IP
1. **Backend:** Already bound to all interfaces (0.0.0.0)
2. **Flutter:** Edit `lib/services/*_service.dart`
3. **Arduino:** Edit lines 7-8 in `.ino` file
4. **Dashboard:** Edit line 241 in `index.html`

### Change WiFi
1. **Arduino:** Edit lines 4-5 in `.ino` file
2. **Devices:** Connect to new network
3. **Backend:** No changes needed (binds to all)

### Change Port
1. **Backend:** Edit `bin/server.dart` line ~135
2. **Flutter:** Edit all services
3. **Arduino:** Edit line 8
4. **Dashboard:** Edit WS_URL

## Monitoring

### Backend Logs
```
Look for:
- "Server running on..."
- "WebSocket client connected"
- "Broadcasted to X clients"
```

### Flutter Debug
```dart
// Add print statements
print('WebSocket status: ${wsService.isConnected}');
print('Orders loaded: ${orders.length}');
```

### Arduino Debug
```
Serial Monitor shows:
- WiFi connection status
- RFID scans
- HTTP response codes
- Status updates
```

### Dashboard Console
```javascript
// Open F12 console
console.log('Orders:', orders);
console.log('Socket state:', socket.readyState);
```

## Testing Checklist

- [ ] Backend server starts without errors
- [ ] Dashboard shows "Connected" status
- [ ] Flutter app can login/signup
- [ ] Arduino connects to WiFi
- [ ] Orders appear in mobile app
- [ ] RFID scan triggers status update
- [ ] Dashboard updates in real-time
- [ ] LEDs blink during transitions
- [ ] Order completes full cycle

## Support Resources

1. **README.md** - Project overview and features
2. **SETUP_GUIDE.md** - Detailed setup instructions
3. **SYSTEM_ARCHITECTURE.md** - Technical architecture
4. **PROJECT_SUMMARY.md** - Complete project summary

## Emergency Recovery

### Reset Everything
```bash
# Stop backend
Ctrl+C

# Clear Flutter cache
flutter clean

# Reset Arduino
Press RESET button

# Restart backend
dart run bin/server.dart

# Rebuild Flutter
flutter run

# Reload dashboard
F5 in browser
```

### Reset Database
```bash
cd backend/data
rm users.json orders.json
# Restart backend to create fresh files
```

## Performance Tips

1. **Backend:** Don't run multiple instances
2. **Flutter:** Enable release mode for better performance
3. **Arduino:** Keep Serial Monitor closed when not debugging
4. **Dashboard:** Close unused browser tabs

## Version Info
```
Flutter:  3.x+
Dart:     3.0+
Android:  API 23+ (Android 6.0+)
Arduino:  ESP8266/ESP32
Browser:  Modern (Chrome, Firefox, Edge, Safari)
```

---

**Quick Help:**
- Backend not starting? Check port 8080
- Can't connect? Verify WiFi "db"
- No updates? Check WebSocket connection
- Arduino issues? Check Serial Monitor (115200)

**Emergency Contact:**
- Check logs in Serial Monitor / Console
- Review SETUP_GUIDE.md for troubleshooting
- Verify all devices on same network

---

*Keep this card handy during development and deployment!*
