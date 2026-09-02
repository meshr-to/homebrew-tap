cask "meshr" do
  version "0.7.154"
  sha256 "979f71aba7d1ade53c8d89b9df4efee3a130cd408f383d169b4f0a1995e665d4"

  url "https://get.meshr.to/releases/v#{version}/Meshr-v#{version}-macOS.dmg"
  name "Meshr"
  desc "Zero-trust WireGuard mesh for your devices, SSH, and services"
  homepage "https://meshr.to/"

  depends_on macos: :big_sur

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
