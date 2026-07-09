# MacUpdateButton

MacUpdateButton ist eine kleine native macOS-App, mit der wir gemeinsam eine einfache „Ein-Knopf“-Aktualisierung für deine Software bauen.

## Ziel

Version `0.0.1` startet bewusst klein:

- native macOS-App mit SwiftUI
- ein großer Button: **Updates starten**
- führt Homebrew-Updates aus, wenn Homebrew installiert ist
- führt Mac-App-Store-Updates mit `mas` aus, wenn `mas` installiert ist
- zeigt macOS-Systemupdates an, installiert sie aber in v0.0.1 noch nicht automatisch
- protokolliert die Ausgabe sichtbar in der App

## Warum Systemupdates noch nicht automatisch?

`softwareupdate -i -a` kann Admin-Rechte, Neustarts und längere Sperren benötigen. Für die erste Version bleibt das bewusst sicher: anzeigen ja, automatisch installieren später nach gemeinsamer Entscheidung.

## Entwicklung

Voraussetzungen:

- macOS
- Xcode oder Xcode Command Line Tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

Projekt generieren:

```bash
xcodegen generate
```

Build/Test:

```bash
xcodebuild test -project MacUpdateButton.xcodeproj -scheme MacUpdateButton -destination 'platform=macOS'
```

## Version

Aktuelle Startversion: `0.0.1`
