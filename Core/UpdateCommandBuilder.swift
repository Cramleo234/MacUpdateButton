import Foundation

public struct UpdateSelection: Equatable {
    public var includeHomebrew: Bool
    public var includeMas: Bool
    public var includeSystemUpdateCheck: Bool

    public init(includeHomebrew: Bool = true, includeMas: Bool = true, includeSystemUpdateCheck: Bool = true) {
        self.includeHomebrew = includeHomebrew
        self.includeMas = includeMas
        self.includeSystemUpdateCheck = includeSystemUpdateCheck
    }

    public var hasAnySelection: Bool {
        includeHomebrew || includeMas || includeSystemUpdateCheck
    }
}

public enum UpdateCommandBuilder {
    public static func displaySteps(for selection: UpdateSelection = UpdateSelection()) -> [String] {
        var steps: [String] = []

        if selection.includeHomebrew {
            steps.append("Homebrew aktualisieren, upgraden und aufräumen")
        }

        if selection.includeMas {
            steps.append("Mac-App-Store-Apps mit mas aktualisieren")
        }

        if selection.includeSystemUpdateCheck {
            steps.append("macOS-Systemupdates anzeigen, ohne sie automatisch zu installieren")
        }

        return steps
    }

    public static func updateCommand(selection: UpdateSelection = UpdateSelection()) -> String {
        var commands = [
            "set -o pipefail",
            "echo '== UpdatePilot 0.1.1 =='"
        ]

        if selection.includeHomebrew {
            commands.append(homebrewCommand())
        } else {
            commands.append("echo 'Homebrew wurde abgewählt – überspringe Homebrew-Updates.'")
        }

        if selection.includeMas {
            commands.append(masCommand())
        } else {
            commands.append("echo 'Mac-App-Store-Updates wurden abgewählt – überspringe mas.'")
        }

        if selection.includeSystemUpdateCheck {
            commands.append(systemUpdateCheckCommand())
        } else {
            commands.append("echo 'macOS-Systemupdate-Anzeige wurde abgewählt.'")
        }

        commands.append("echo '== Update-Lauf beendet =='")
        return commands.joined(separator: "\n")
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
echo 'Hinweis: macOS-Systemupdates werden nur angezeigt, nicht automatisch installiert.'
"""
    }
}
