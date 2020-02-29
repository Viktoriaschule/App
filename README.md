# app

## Konfiguration
1. Projekt klonen: `git clone https://github.com/Viktoriaschule/App.git`
2. [Flutter installieren](https://flutter.dev/docs/get-started/install)
2. Script zum Icons-Generieren starten: `dart scripts/icons.dart`

### Android
1. Key-Datei für die Appsignatur erstellen (Zum Beispiel mit der Hilfe von Android Studio (Build/Generate Signed APK und nach der Erstellung des Keys den build Prozess einfach abbrechen))
2.  Datei `app_frame/android/key.properties` mit folgendem Inhalt erstellen:
```
keyPassword=PASSWORD
storePassword=PASSWORD
keyAlias=KEY
storeFile=PATH_TO_GENERATED_KEY_FILE
```
3. Die `google-services.json` Datei von [Firebase](https://console.firebase.google.com/) downloaden
    - Projekt auswählen
    - Oben links: Einstellungen - Meine Apps - google-services.json
    - Datei in `app_frame/android/app/google-services.json` speichern

### Apple
...