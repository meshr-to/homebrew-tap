cask "meshr" do
  version "1.2.3"
  sha256 "c49ff2a8e30b15607679d4c5cc07b43b315f171bb440f6a18d0606964518e2ce"

  url "https://get.meshr.to/releases/v#{version}/Meshr-v#{version}-macOS.dmg"
  name "Meshr"
  desc "WireGuard-based mesh networking — GUI, CLI, and daemon"
  homepage "https://meshr.to/"

  depends_on macos: ":big_sur"

  app "Meshr.app"

  postflight do
    # Symlink the meshr CLI to /usr/local/bin so `meshr` is on PATH.
    system_command "/bin/ln",
                   args: ["-sf", "#{appdir}/Meshr.app/Contents/MacOS/meshr", "/usr/local/bin/meshr"],
                   sudo: true

    # Stamp the install-method marker so meshr update / OpUpdate picks the
    # brew-cask upgrade path instead of binary-replace.
    # See backend/agent/internal/update/detect.go for the consumer.
    system_command "/bin/mkdir", args: ["-p", "/etc/meshr"], sudo: true
    system_command "/usr/bin/tee", args: ["/etc/meshr/install-method"], input: "brew", sudo: true
  end

  uninstall quit: "to.meshr.app"

  zap trash: [
    "/etc/meshr/install-method",
    "/usr/local/bin/meshr",
    "~/Library/Application Support/Meshr",
  ]
end
