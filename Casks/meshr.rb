cask "meshr" do
  version "0.4.12"
  sha256 "PLACEHOLDER"

  url "https://releases.meshr.to/v#{version}/Meshr-v#{version}-macOS.dmg"
  name "Meshr"
  desc "WireGuard-based mesh networking — GUI, CLI, and daemon"
  homepage "https://meshr.to"

  depends_on macos: ">= :big_sur"

  app "Meshr.app"

  postflight do
    # Symlink CLI tools to /usr/local/bin
    system_command "/bin/ln", args: ["-sf", "#{appdir}/Meshr.app/Contents/MacOS/meshr", "/usr/local/bin/meshr"], sudo: true
    system_command "/bin/ln", args: ["-sf", "#{appdir}/Meshr.app/Contents/MacOS/meshr-daemon", "/usr/local/bin/meshr-daemon"], sudo: true
  end

  uninstall quit: "to.meshr.app"

  zap trash: [
    "~/Library/Application Support/Meshr",
    "~/Library/LaunchAgents/to.meshr.daemon.plist",
    "/usr/local/bin/meshr",
    "/usr/local/bin/meshr-daemon",
  ]
end
