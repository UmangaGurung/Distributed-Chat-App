# Distributed Chat App

![Architecture Diagram](./diagram-export-2-2-2026-11_15_07-PM.png)

## Features:
- Real-time message delivery
- One-on-one and Group chats
- Chat initatiation through registrated phone number
- Create group conversations similar to WhatsApp
- Message history/persistence and offline viewing
- Typing indicators

## Technical Overview:  
- Supports running multiple instances of chatservice
- Redis pub/sub for broadcasting messages between server instances
- gRPC for communicating between chatservice and userservice
- Redis for caching gRPC responses
- Hive for caching API responses
- Both traditional registration/login and Google OAuth
- AES/GCM for message encryption

### Getting Started
**Note**: *You can build and run the project using either `docker` or `podman`. Since podman is daemonless and doesn't cause permission issues, I would suggest using podman instead.*

#### 1. Clone the repository:

   Run the following command to clone the repository:
  
   ```bash
   git clone https://github.com/UmangaGurung/Distributed-Chat-App.git
   ```

#### 2. Running chatservice

   Navigate to the project directory:
   ```bash
   cd Distributed-Chat-App/backend/userservice/
   ```
   Build the containers:
   ```bash
   podman-compose build --no-cache
   ```

   
   **_Make sure there are no services running on ports that may conflict with the ports defined in the `Dockerfile`._**
   
   Start up the containers:
   ```bash
   podman-compose up
   ```

#### 3. Running userservice

   **_The chatservice connects to the same redis container exposed by the userserive. So, the chatservice may fail to initialize redis if userservice is not running._**

   Navigate to the project directory:
   ```bash
   cd Distributed-Chat-App/backend/chatservice/
   ```
   Build the containers:
   ```bash
   podman-compose build --no-cache
   ```
   Start up the containers:
   ```bash
   podman-compose up
   ```

#### 4. Running the frontend

   *Open the frontend/chatfrontend folder from any IDE or code editor that supports dart and flutter.*
   
   Install dependencies:
   ```bash
   flutter pub get
   ```

   **Note:** *If the .g files aren't being recognized by your IDE/editor.*
   Run:
   ```bash
   flutter pub run build_runner build
   ```
   Run the app:
   ```bash
   flutter run
   ```

   **Note:** *If you're using a physical device instead of an emulator, be sure to specify your Ip address in the environment variable.*
   ```bash
   flutter run --dart-define=HOST=youidaddress
   ```
