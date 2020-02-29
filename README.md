# app

## Konfiguration
1. Klonen des Projektes: `git clone https://github.com/Viktoriaschule/App.git`
2. [Dart installieren](https://dart.dev/get-dart), falls dies noch nicht der Fall ist
2. Starte das Script zum Icons-Generieren: `dart scripts/icons.dart`

### Android
1. Erstelle eine Key-Datei für die Appsignatur
    - Zum Beispiel mithilfe von Android Studio (Build/Generate Signed APK und nach der Erstellung des Keys, den build Prozess einfach abbrechen)
2. Erstelle die Datei `app_frame/android/key.properties` mit folgendem Inhalt:

```
keyPassword=PASSWORD
storePassword=PASSWORD
keyAlias=KEY
sotreFile=PATH_TO_GENERATED_KEY_FILE
```
3. Downloade die `google-services.json` Datei von [Firebase](https://console.firebase.google.com/)
    - Projekt Auswählen
    - Oben links: Einstellungen - Meine Apps - google-services.json
    - Speicher diese Datei in `app_frame/android/app/google-services.json`

### Apple
...