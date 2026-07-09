import Foundation

public enum UpdateCommandBuilder {
    public static let displaySteps: [String] = [
        "Homebrew aktualisieren, falls installiert",
        "Homebrew-Pakete upgraden und aufräumen",
        "Mac-App-Store-Apps mit mas aktualisieren, falls installiert",
        "macOS-Systemupdates anzeigen, ohne sie automatisch zu installieren"
    ]

    public static func updateCommand() -> String {
        [
            "set -o pipefail",
            "echo '== MacUpdateButton 0.0.1 =='",
            homebrewCommand(),
            masCommand(),
            systemUpdateCheckCommand(),
            "echo '== Update-Lauf beendet =='"
        ].joined(separator: "\n")
    }

    public static func homebrewCommand() -> String {
        """
if command -v brew >/dev/null 2>&1; then
  echo '== Homebrew: update =='
  brew update
  echo '== Homebrew: upgrade =='
  brew upgrade
  echo '== Homebrew: cleanup =='
  brew cleanup
else
  echo 'Homebrew nicht gefunden – überspringe Homebrew-Updates.'
fi
"""
    }

    public static func masCommand() -> String {
        """
if command -v mas >/dev/null 2>&1; then
  echo '== Mac App Store: upgrade =='
  mas upgrade
else
  echo 'mas nicht gefunden – Mac-App-Store-Updates werden übersprungen.'
fi
"""
    }

    public static func systemUpdateCheckCommand() -> String {
        """
echo '== macOS-Systemupdates: verfügbare Updates =='
softwareupdate -l || true
echo 'Hinweis: macOS-Systemupdates werden in Version 0.0.1 nur angezeigt, nicht automatisch installiert.'
"""
    }
}
