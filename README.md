# GlycoSnap
This repository contains the mobile app and website
- Website: https://glycosnap.jhubafrica.com/

## 🚀Features:
✅ Food recognition with YOLOv8
✅ Glycemic load estimation
✅ Portion size approximation

### Mobile app
This branch contains:
- A Flask backend (glycosnap_flask) running in a Docker container.
- A Flutter mobile app (glycosnap_flutter) that communicates with the Flask API.

## Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your machine.
- [Docker Compose](https://docs.docker.com/compose/install/) (usually comes with Docker Desktop).
- [Flutter](https://flutter.dev/docs/get-started/install) for running the mobile app (optional if you run the app via VS Code).

## Getting Started
# 1. Clone the repository: https://github.com/GlycoSnap/GlycoSnap.git
cd glycosnap

# 2. Build and Run the Flask Backend (glycoSnap_flask)
The backend (model) runs inside a Docker container. Note: Building the container can take up to an hour depending on your machine.

- Navigate to the project root (where your docker-compose.yml is located).
- Build and run the Flask container: docker-compose up --build model
- This command builds the Docker image for the Flask backend and starts the container.
- The container maps its internal port 5000 to your host's port 5000.
# Important: When the build is complete, check your host's IP address (e.g., using ipconfig on Windows or ifconfig/ip a on macOS/Linux).

# 3. Verify the Flask API is Running:
- Open a web browser and navigate to: http://<your-host-ip>:5000/
- You should see a message like:
{"message": "GlycoSnap API is running!"}

# 4. Configure the Flutter Mobile App
- Open the Flutter Project in VS Code:
- Open the project folder in VS Code.
- Update the API URL: In your Flutter code, locate add_food.dart where the Flask API URL is defined. Change the URL to point to your host’s IP address on port 5000 e.g final String baseUrl = 'http://192.168.100.12:5000/predict';
- Connect Your Mobile Device: Connect your phone via USB (or start an emulator).
- Ensure that your device is detected by running:
flutter devices
- Run the Flutter App: Launch the app from VS Code or run:
flutter run -d <device-id>

# 5. Additional Notes
- Docker & USB Devices:
The Flask backend runs in Docker, but the Flutter app runs natively so that it can access your mobile device via USB or emulator. This is a standard setup for local development.

- API URL Consistency:
Since the Flask container’s internal IP (e.g., 172.18.0.2) is not accessible outside Docker, always use your host machine’s IP (e.g., 192.168.100.12) for the API URL.
