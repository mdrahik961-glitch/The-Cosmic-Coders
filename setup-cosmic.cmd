@echo off
setlocal

echo.
echo ==========================================
echo Cosmic Public MVP Setup Starting...
echo ==========================================
echo.

if not exist src (
  echo [ERROR] src folder paoa jay ni.
  echo Ei script project root folder theke run korte hobe.
  pause
  exit /b 1
)

if not exist src\lib mkdir src\lib

if exist src\App.tsx (
  copy /Y src\App.tsx src\App.backup.tsx >nul
  echo [OK] Backup created: src\App.backup.tsx
)

(
echo import { initializeApp } from "firebase/app";
echo import { getAuth } from "firebase/auth";
echo import { getFirestore } from "firebase/firestore";
echo.
echo const firebaseConfig = {
echo   apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
echo   authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
echo   projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
echo   storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
echo   messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
echo   appId: import.meta.env.VITE_FIREBASE_APP_ID,
echo };
echo.
echo const app = initializeApp(firebaseConfig);
echo.
echo export const auth = getAuth(app);
echo export const db = getFirestore(app);
) > src\lib\firebase.ts
echo [OK] Created src\lib\firebase.ts

(
echo VITE_FIREBASE_API_KEY=your_firebase_api_key
echo VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
echo VITE_FIREBASE_PROJECT_ID=your_project_id
echo VITE_FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
echo VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
echo VITE_FIREBASE_APP_ID=your_app_id
echo VITE_NASA_API_KEY=your_nasa_api_key
) > .env.example
echo [OK] Created .env.example

(
echo rules_version = '2';
echo service cloud.firestore {
echo   match /databases/{database}/documents {
echo.
echo     function signedIn() {
echo       return request.auth != null;
echo     }
echo.
echo     function isOwner(uid) {
echo       return signedIn() && request.auth.uid == uid;
echo     }
echo.
echo     match /users/{uid} {
echo       allow read: if isOwner(uid);
echo       allow create: if isOwner(uid) && request.resource.data.email == request.auth.token.email;
echo       allow update: if isOwner(uid);
echo       allow delete: if false;
echo     }
echo.
echo     match /comments/{commentId} {
echo       allow read: if signedIn();
echo       allow create: if signedIn()
echo         && request.resource.data.userId == request.auth.uid
echo         && request.resource.data.text is string
echo         && request.resource.data.text.size() ^> 0
echo         && request.resource.data.text.size() ^<= 1000;
echo       allow update, delete: if false;
echo     }
echo.
echo     match /visitorLogs/{logId} {
echo       allow create: if signedIn()
echo         && request.resource.data.uid == request.auth.uid;
echo       allow read, update, delete: if false;
echo     }
echo   }
echo }
) > firestore.rules
echo [OK] Created firestore.rules

(
echo {
echo   "hosting": {
echo     "public": "dist",
echo     "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
echo     "rewrites": [
echo       {
echo         "source": "**",
echo         "destination": "/index.html"
echo       }
echo     ]
echo   },
echo   "firestore": {
echo     "rules": "firestore.rules"
echo   }
echo }
) > firebase.json
echo [OK] Created firebase.json

echo.
echo Installing firebase package...
call npm install firebase

echo.
echo ==========================================
echo Done.
echo Next steps:
echo 1. Copy .env.example to .env
echo 2. Put your real Firebase and NASA keys
echo 3. Run: npm run dev
echo ==========================================
echo.
pause
