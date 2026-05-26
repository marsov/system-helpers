# system-helpers

A collection of scripts and small utilities for setting up development environments and simplifying common system tasks.

This repository groups together platform-specific helpers for Linux, macOS, and Windows so it is easier to bootstrap a machine, automate repetitive setup steps, and keep useful system commands in one place.

## Available scripts

### Linux

- `linux/common-aliases.sh` - Shared shell aliases for Linux, including shortcuts for Docker, Git, directory navigation, system info, and package update commands.
- `linux/fedora/sha256.sh` - Verifies a file's SHA256 checksum against an expected hash on Fedora and other Linux systems with `sha256sum`.
- `linux/ubuntu/copilot.sh` - Small installer helper for GitHub Copilot-related tooling on Ubuntu.
- `linux/ubuntu/setup-dev-environment.sh` - Ubuntu development environment bootstrap script that installs common tools such as Git, Docker, Node.js, Python, .NET, VS Code, cloud CLIs, `kubectl`, Terraform, and GitHub CLI, then sets up aliases and common development folders.

### macOS

- `macos/sha256.sh` - Verifies a file's SHA256 checksum against an expected hash using macOS `shasum`.

### Windows 11

- `win11/setup-dev-environment.ps1` - PowerShell setup script for preparing a Windows 11 development machine with Winget packages, Windows features like WSL2 and Hyper-V, PowerShell modules, Git configuration, environment variables, and common development directories.

