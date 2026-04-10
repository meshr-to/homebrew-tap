cask "meshr" do
  version "0.4.18"
  sha256 "beff35c24278bdc9e2de310f734cbde7ff59722f264a8ded7675e8688f37579a"

  url "https://releases.meshr.to/v#{version}/Meshr-v#{version}-macOS.dmg"
  name "Meshr"
  desc "WireGuard-based mesh networking — CLI, daemon, and menubar tray"
  homepage "https://meshr.to"

  app "Meshr.app"

  postflight do
    # Strip the quarantine xattr so Gatekeeper doesn't block the unsigned bundle
    # (Meshr is not yet notarized by Apple Developer ID).
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/Meshr.app"]

    # Symlink CLI tools to /usr/local/bin
    system_command "/bin/ln", args: ["-sf", "#{appdir}/Meshr.app/Contents/MacOS/meshr", "/usr/local/bin/meshr"], sudo: true
    system_command "/bin/ln", args: ["-sf", "#{appdir}/Meshr.app/Contents/MacOS/meshr-daemon", "/usr/local/bin/meshr-daemon"], sudo: true
  end

  uninstall quit:    "to.meshr.app",
            signal:  ["TERM", "meshr-tray"],
            pkgutil: "to.meshr.*"

  zap trash: [
    "~/Library/Application Support/Meshr",
    "~/Library/LaunchAgents/to.meshr.daemon.plist",
    "/usr/local/bin/meshr",
    "/usr/local/bin/meshr-daemon",
  ]
end
