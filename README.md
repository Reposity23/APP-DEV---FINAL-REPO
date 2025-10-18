# Smart Toy Store - Full System Documentation


<img width="1006" height="626" alt="image" src="https://github.com/user-attachments/assets/c2631c47-20a7-4bfc-85c0-a950944eb441" />

#  Toy Store System
MEMBERS:
JANNALYN CRUZ <br>
JOHN MARWIN EBONA<br>
PRINCE MARL LIZANDRELLE MIRASOL<br>
RENZ CHRISTIANE MING

note to self:
git add .
git commit -m "fix cors and server connection"
git branch -M main
git remote remove origin
git remote add origin https://github.com/Reposity23/APP-DEV---FINAL-REPO.git
git push -u origin main


    netstat -ano | findstr :8080
    
    taskkill /PID 26680 /F
    - kill task
## 1. System Architecture

The system is a full-stack, real-time order processing and tracking application designed for a toy factory. It consists of four main components:

1.  **Flutter Mobile App:** The customer-facing storefront. Users can browse a catalog of toys, register for an account, and place orders. It communicates with the backend server over the local network.

2.  **Dart Backend Server:** The central hub of the entire system. It runs on a laptop and is responsible for:
    *   Handling API requests (login, signup, order creation).
    *   Maintaining a persistent JSON database for users and orders.
    *   Serving the HTML dashboard to web clients.
    *   Broadcasting real-time updates to all connected clients (Dashboard and Arduino) via WebSockets.

3.  **HTML5 Dashboard:** The factory floor interface. It provides a real-time overview of all orders, including their status and assigned worker. It plays audio alerts for new orders.

4.  **Arduino (ESP8266):** The physical interface for the factory floor. It connects to the WiFi network, receives order updates, and controls LEDs to signal new tasks. Workers use an RFID scanner connected to it to update the status of an order.

### System Flow Diagram

```
+-----------------+      +--------------------+      +-----------------+
|USER'S Phone App |----->|  Laptop Backend    |<---->|  HTML Dashboard |
| (Flutter)       |      |  (Dart Server)     |      |  (Web Browser)  |
+-----------------+      | - API (HTTP)       |      +-----------------+
                         | - Real-time (WS)   |
                         | - Database (JSON)  |
                         +--------+-----------+
                                  ^
                                  |
                       +----------+---------+
                       |  Arduino (ESP8266) |
                       | - Lights (LEDs)    |
                       | - Scanner (RFID)   |
                       +--------------------+
```

---

## 2. Core Features

*   **Mobile-First Ordering:** A user-friendly mobile app for customers to browse and buy toys.
*   **Real-Time Dashboard:** A live dashboard for factory managers to monitor all incoming orders.
*   **Physical Task Signaling:** An Arduino-powered system with LEDs to provide clear, physical signals to factory workers.
*   **RFID-Based Workflow:** Workers use an RFID scanner to update an order's status through the stages: `PROCESSING` -> `ON_THE_WAY` -> `DELIVERED`.
*   **Persistent Storage:** Orders are saved to the server's disk and will survive a server restart.
*   **Audio Alerts:** The dashboard plays a unique sound for each toy category when a new order arrives, alerting the relevant worker.
*   **Hardcoded Worker Assignments:** Each order is automatically assigned to a specific factory worker based on the toy category.
*   **Role-Specific UI:** The mobile app is for customers; the dashboard is for factory staff.

---

## 3. Setup and Operation Guide

Follow these steps to run the entire system.

### Step 1: Network Configuration

1.  **Create a WiFi Hotspot** on your laptop with the following settings:
    *   **SSID:** `db`
    *   **Password:** `123456789`
2.  **Assign a Static IP Address** to your laptop's hotspot adapter.
    *   The IP address **must** be `192.168.137.1`.
    *   The Subnet Mask should be `255.255.255.0`.

### Step 2: Backend Server Setup

1.  Open a terminal and navigate to the `backend` directory:
    ```sh
    cd C:\Users\johnt\OneDrive\Desktop\app_dev_2\backend
    ```
2.  Install all required dependencies:
    ```sh
    dart pub get
    ```
3.  Run the server:
    ```sh
    dart run bin/server.dart
    ```
4.  The server should now be running. You will see the message: `Server running on http://0.0.0.0:8080`.

> **Troubleshooting:** If you see an `address already in use` error, it means an old server process is stuck. Open the Task Manager, find any `dart.exe` processes, and end them.

### Step 3: Flutter App Setup (for JM's Phone)

1.  **Prepare Assets:** Ensure the directory `assets/images/` exists in the root of the project. Place your toy images here (e.g., `toy_gun_1.png`).
2.  **Install & Run:** Build and install the app on an Android phone connected to your laptop's hotspot (`db`).
3.  **Functionality:**
    *   Users can sign up without providing a department.
    *   Users can browse the toy store, search for products, and place orders.

### Step 4: Arduino Setup

1.  Open the `arduino/smart_toy_rfid.ino` sketch in the Arduino IDE.
2.  **Verify Configuration:** Ensure the `serverIP` is set to `192.168.137.1`.
3.  **Upload the Sketch** to your ESP8266 device.
4.  **LED Color Logic:**
    *   `Dolls`: Green
    *   `Puzzles`: Red
    *   `Action Figures`: Yellow (Red + Green LEDs)
    *   `Toy Guns`: Blue

### Step 5: Dashboard Access

1.  On any device connected to the hotspot (including your laptop or another phone), open a web browser.
2.  Navigate to the server's URL:
    ```
    http://192.168.137.1:8080
    ```
3.  **Click the "Enable Sound & Enter" button.** This is a mandatory one-time step to comply with browser security policies.
4.  The dashboard will load, display all persistent orders, and play sounds for new ones.

---

## 4. System Workflow

1.  **Order Placement:** A customer on the Flutter app buys a "Laser Ray Gun".
2.  **Backend Processing:** The app sends the order to the backend. The backend assigns **John Marwin** to the order and saves it to `orders.json`.
3.  **Real-Time Notifications:** The backend sends a WebSocket message to all clients.
4.  **Dashboard Update:** The HTML dashboard receives the message, adds the "Laser Ray Gun" order to the table, and plays an mp3 for example: `lorem.mp3` sound.
5.  **Arduino Action:** The Arduino is now aware an order for a "Toy Gun" exists.
6.  **Factory Work:** a user  gets the toy. the person who was assign to the order scans the RFID tag for example (`TG01_UID`) on the Arduino scanner.
7.  **Arduino Update:** The Arduino's **Blue LED turns on**. The Arduino sends a `POST` request to `/api/updateStatus` with the new status `PROCESSING`.
8.  **Backend Update:** The backend updates the order in the database.
9.  **Live Sync:** The backend broadcasts the status change. The dashboard and Flutter app update to show the order is now `PROCESSING`.
10. **Completion:** This process repeats for `ON_THE_WAY` and `DELIVERED`. After the final scan, the Arduino's Blue LED turns off.

