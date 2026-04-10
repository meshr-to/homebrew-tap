cask "meshr" do
  version "0.4.18"
  sha256 "beff35c24278bdc9e2de310f734cbde7ff59722f264a8ded7675e8688f37579a"

  url "https://releases.meshr.to/v#{version}/Meshr-v#{version}-macOS.dmg"
  name "Meshr"
  desc "WireGuard-based mesh networking — CLI, daemon, and menubar tray"
  homepage "https://meshr.to/"

  app "Meshr.app"

  postflight do
    require "fileutils"

    app_path   = "#{appdir}/Meshr.app/Contents/MacOS"
    daemon_bin = "#{app_path}/meshr-daemon"
    tray_bin   = "#{app_path}/meshr-tray"

    # 1. Strip the quarantine xattr so Gatekeeper doesn't block the unsigned bundle
    #    (meshr is not yet notarized by Apple Developer ID).
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/Meshr.app"]

    # 2. Symlink CLI tools to /usr/local/bin
    system_command "/bin/ln", args: ["-sf", "#{app_path}/meshr", "/usr/local/bin/meshr"], sudo: true
    system_command "/bin/ln", args: ["-sf", daemon_bin, "/usr/local/bin/meshr-daemon"], sudo: true

    # 3. Install system-wide LaunchDaemon (runs meshr-daemon as root at boot)
    daemon_plist = "/Library/LaunchDaemons/to.meshr.daemon.plist"
    daemon_plist_content = <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>to.meshr.daemon</string>
          <key>ProgramArguments</key>
          <array>
              <string>/usr/local/bin/meshr-daemon</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
          <key>StandardOutPath</key>
          <string>/var/log/meshr-daemon.log</string>
          <key>StandardErrorPath</key>
          <string>/var/log/meshr-daemon.err</string>
      </dict>
      </plist>
    PLIST
    tmp_daemon_plist = "/tmp/to.meshr.daemon.plist"
    File.write(tmp_daemon_plist, daemon_plist_content)
    system_command "/bin/mv", args: [tmp_daemon_plist, daemon_plist], sudo: true
    system_command "/usr/sbin/chown", args: ["root:wheel", daemon_plist], sudo: true
    system_command "/bin/chmod", args: ["644", daemon_plist], sudo: true
    # Unload if previously loaded, then load + start
    system_command "/bin/launchctl", args: ["unload", daemon_plist], sudo: true, must_succeed: false
    system_command "/bin/launchctl", args: ["load", "-w", daemon_plist], sudo: true

    # 4. Install per-user LaunchAgent for tray (runs at login, starts now)
    agent_dir   = "#{Dir.home}/Library/LaunchAgents"
    agent_plist = "#{agent_dir}/to.meshr.tray.plist"
    FileUtils.mkdir_p(agent_dir)
    agent_plist_content = <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>to.meshr.tray</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{tray_bin}</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <dict>
              <key>SuccessfulExit</key>
              <false/>
          </dict>
          <key>ProcessType</key>
          <string>Interactive</string>
          <key>LimitLoadToSessionType</key>
          <array>
              <string>Aqua</string>
          </array>
          <key>StandardOutPath</key>
          <string>/tmp/meshr-tray.log</string>
          <key>StandardErrorPath</key>
          <string>/tmp/meshr-tray.err</string>
      </dict>
      </plist>
    PLIST
    File.write(agent_plist, agent_plist_content)
    # Unload if previously loaded, then load + start (current user, no sudo)
    system_command "/bin/launchctl", args: ["unload", agent_plist], must_succeed: false
    system_command "/bin/launchctl", args: ["load", "-w", agent_plist]
  end

  uninstall launchctl: [
              "to.meshr.daemon",
              "to.meshr.tray",
            ],
            quit:      "to.meshr.app",
            signal:    ["TERM", "meshr-tray"],
            pkgutil:   "to.meshr.*",
            delete:    [
              "/Library/LaunchDaemons/to.meshr.daemon.plist",
              "/usr/local/bin/meshr",
              "/usr/local/bin/meshr-daemon",
            ]

  zap trash: [
    "/Library/LaunchDaemons/to.meshr.daemon.plist",
    "/tmp/meshr-tray.err",
    "/tmp/meshr-tray.log",
    "/usr/local/bin/meshr",
    "/usr/local/bin/meshr-daemon",
    "/var/log/meshr-daemon.err",
    "/var/log/meshr-daemon.log",
    "~/Library/Application Support/Meshr",
    "~/Library/LaunchAgents/to.meshr.daemon.plist",
    "~/Library/LaunchAgents/to.meshr.tray.plist",
  ]
end
