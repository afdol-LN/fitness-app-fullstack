# fitness-app-fullstack

- `flutter_application_1/` — Flutter app
- `my_app_server/` — Node.js (Express) + MariaDB server

## Setup after clone

### 1. Database
You need MariaDB/MySQL with a database named `my_fitness` (ask the owner for the `.sql` dump and import it).

### 2. Server
```bash
cd my_app_server
npm install
cp config/db.config.example.js config/db.config.js
```
Edit `config/db.config.js` and set your own DB user/password, then:
```bash
npm start
```
The server runs at `http://localhost:3000`.

### 3. Flutter app
```bash
cd flutter_application_1
flutter pub get
flutter run
```
If you run on a phone or Android emulator, change `localhost` in
`lib/config/app.config.dart` to your computer's IP address.
