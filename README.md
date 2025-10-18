#  Toy Store System 
  MEMBERS:
JANNALYN CRUZ <br>
JOHN MARWIN EBONA<br>
PRINCE MARL LIZANDRELLE MIRASOL<br>
RENZ CHRISTIANE MING


A complete real-time LAN-connected ecosystem for toy store operations featuring Flutter mobile app, Dart backend server, Arduino IoT integration, and HTML dashboard.

## System Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │── ─▶│  Shelf Backend   │◀───│   Arduino ESP   │
│  (Mobile)       │     │  (WebSocket)     │     │  (RFID Reader)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │  HTML Dashboard  │
                        │  (Web Browser)   │
                        └──────────────────┘
```

## Network Configuration

- **SSID:** db
- **Password:** 123456789
- **Backend IP:** 10.40.190.130
- **Backend Port:** 8080
- **WebSocket URL:** ws://10.40.190.130:8080/ws
- **HTTP API:** http://10.40.190.130:8080

## Components

### 1. Flutter Mobile App (Android)
- Material Design 3 UI
- JWT Authentication
- Real-time WebSocket updates
- Offline caching with Hive
- Order management and tracking
- Android Embedding v2 compliant

### 2. Dart Shelf Backend Server
- RESTful API endpoints
- WebSocket server for real-time communication
- JWT authentication
- JSON file-based storage
- CORS enabled

### 3. Arduino ESP8266/ESP32
- WiFi connectivity
- RFID UID processing
- LED status indicators
- Automatic status updates
- HTTP client for backend communication

### 4. HTML/JavaScript Dashboard
- Real-time order monitoring
- WebSocket client
- Live statistics
- Status animations
- Responsive design

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.0 or higher
- Arduino IDE with ESP8266/ESP32 board support
- WiFi hotspot named "db" with password "123456789"
- Laptop/computer with IP 10.40.190.130

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
dart pub get
```

3. Run the server:
```bash
dart run bin/server.dart
```

The server will start on http://10.40.190.130:8080

### Flutter App Setup

1. Navigate to project root:
```bash
cd project
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Arduino Setup

1. Open `arduino/smart_toy_rfid.ino` in Arduino IDE

2. Install required libraries:
   - ESP8266WiFi (for ESP8266)
   - ESP8266HTTPClient
   - ArduinoJson

3. Select your board (ESP8266 or ESP32)

4. Upload the code to your device

5. Open Serial Monitor to see status and simulate RFID scans

### Dashboard Setup

1. Open `dashboard/index.html` in a web browser

2. The dashboard will automatically connect to the WebSocket server

## Usage

### Order Flow

1. **Create Order** (Mobile App):
   - Login to the Flutter app
   - Create a new order with RFID UID and category

2. **RFID Scan** (Arduino):
   - Enter RFID UID in Serial Monitor
   - Arduino sends status update to backend

3. **Status Updates**:
   - PENDING → PROCESSING (5 seconds)
   - PROCESSING → ON_THE_WAY (5 seconds)
   - ON_THE_WAY → DELIVERED (5 seconds)

4. **Real-time Sync**:
   - All devices receive updates via WebSocket
   - Mobile app shows status with animations
   - Dashboard displays live order table
   - Arduino LEDs blink during transitions

### RFID Mappings

| RFID UID | Category        | LED Color |
|----------|----------------|-----------|
| A12B3C   | Toy Guns       | Red       |
| D44F8Z   | Action Figures | Green     |
| E77K9L   | Dolls          | Blue      |
| F23M1N   | Puzzles        | Red       |
| G56P2Q   | Board Games    | Green     |

## API Endpoints

### Authentication
- `POST /login` - User login
- `POST /signup` - User registration

### Orders
- `GET /orders` - Get all orders (requires auth)
- `POST /orders` - Create new order (requires auth)
- `POST /updateStatus` - Update order status (from Arduino)

### WebSocket
- `GET /ws` - WebSocket connection for real-time updates

## Project Structure

```
project/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── toy.dart
│   │   └── order.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── websocket_service.dart
│   │   └── order_service.dart
│   ├── providers/
│   │   └── app_provider.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── home_screen.dart
│   └── widgets/
│       └── order_card.dart
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/example/smarttoystore/
│   │           └── MainActivity.kt
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── backend/
│   ├── bin/
│   │   └── server.dart
│   ├── lib/
│   │   ├── models.dart
│   │   ├── database.dart
│   │   └── auth.dart
│   └── pubspec.yaml
├── arduino/
│   └── smart_toy_rfid.ino
├── dashboard/
│   └── index.html
└── pubspec.yaml
```

## Features

### Flutter App
- JWT authentication with persistent login
- Real-time order updates via WebSocket
- Offline caching with Hive
- Material Design 3 theming
- Order status animations
- Pull-to-refresh
- Tab-based filtering

### Backend
- WebSocket broadcasting to all connected clients
- JWT token generation and verification
- File-based database persistence
- CORS support for web clients
- Request logging

### Arduino
- WiFi auto-reconnect
- RFID mapping system
- LED status indicators with blinking
- Serial monitor for debugging
- Automatic status progression

### Dashboard
- Real-time order monitoring
- Connection status indicator
- Live statistics (total, pending, processing, delivered, revenue)
- Animated status badges
- Responsive design

## Troubleshooting

### Backend Won't Start
- Ensure IP address is correctly set to 10.40.190.130
- Check if port 8080 is available
- Verify WiFi connection to "db" network

### Flutter App Can't Connect
- Check WiFi connection on mobile device
- Verify backend server is running
- Ensure IP address matches in services

### Arduino Not Connecting
- Verify WiFi credentials in code
- Check serial monitor for connection status
- Ensure ESP8266/ESP32 board is properly selected

### Dashboard Not Updating
- Open browser console to check WebSocket connection
- Verify backend server is running
- Check if WebSocket URL is correct

## Technologies Used

- **Frontend:** Flutter 3.x, Dart
- **Backend:** Dart, Shelf, WebSocket
- **Database:** JSON file storage
- **IoT:** Arduino, ESP8266/ESP32
- **Web:** HTML5, JavaScript, WebSocket API
- **Authentication:** JWT
- **Real-time:** WebSocket protocol

## License

This project is part of the Smart Toy Store System ecosystem.
