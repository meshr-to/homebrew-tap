# Homebrew Tap — Meshr

WireGuard-based mesh networking agent for macOS.

## Install

```bash
brew tap meshr-to/meshr
brew install --cask meshr
```

## What's included

- **Meshr.app** — Desktop GUI with system tray
- **meshr** — CLI tool (`/usr/local/bin/meshr`)
- **meshr-daemon** — Background daemon (`/usr/local/bin/meshr-daemon`)

## Usage

```bash
meshr login -t <setup-key>
meshr up
meshr status
```

## Uninstall

```bash
brew uninstall --cask meshr
```

## Links

- Website: https://meshr.to
- Dashboard: https://app.meshr.to
- Docs: https://docs.meshr.to
