# UpdatePilot

Dieses Repository enthält **UpdatePilot**, eine kleine native macOS-App, mit der wir gemeinsam eine einfache „Ein-Knopf“-Aktualisierung für deine Software bauen.

## Ziel

Version `0.0.6` enthält:

- nativer macOS-Name **UpdatePilot**
- neues App-Icon
- ein großer Button: **Updates starten**
- sichere Auswahl, was aktualisiert/geprüft werden soll:
  - Homebrew
  - Mac App Store via `mas`, falls installiert
  - macOS-Systemupdates nur anzeigen
- sichtbares Protokoll in der App, ohne separates Terminalfenster
- baubare `.app` und `.dmg`

## Sicherheitsentscheidung

`softwareupdate -i -a` kann Admin-Rechte, Neustarts und längere Sperren benötigen. Deshalb zeigt UpdatePilot macOS-Systemupdates aktuell nur an. Automatische Systemupdate-Installation bauen wir erst ein, wenn wir gemeinsam festlegen, wie Bestätigung, Neustart und Admin-Rechte sicher funktionieren sollen.

## Installation über Homebrew

```bash
brew tap Cramleo234/tap
brew install --cask updatepilot
```

Alternativ direkt:

```bash
brew install --cask Cramleo234/tap/updatepilot
```

## Entwicklung

Voraussetzungen:

- macOS
- Xcode
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

Projekt generieren:

```bash
xcodegen generate
```

Build/Test:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test -project UpdatePilot.xcodeproj -scheme UpdatePilot -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

Release-App lokal bauen:

```bash
./Scripts/package_dmg.sh
```

Das erzeugt:

- `dist/UpdatePilot.app`
- `dist/UpdatePilot-0.0.6.dmg`

## Version

Aktuelle Version: `0.0.6`

## Lizenz

Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) veröffentlicht.
