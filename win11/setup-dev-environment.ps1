<#
.SYNOPSIS
	Prepares Windows 11 development environment with essential tools and configurations.

.DESCRIPTION
	This script automates the setup of a Windows 11 development environment by:
	- Installing Winget packages (Git, VS Code, Docker, etc.)
	- Configuring Windows features (WSL2, Hyper-V, etc.)
	- Setting up development tools and SDKs
	- Configuring PowerShell profile and environment variables
	- Installing common development frameworks

.PARAMETER SkipWinget
	Skip installation of Winget packages

.PARAMETER SkipWindowsFeatures
	Skip enabling Windows features

.PARAMETER SkipPowerShellModules
	Skip installation of PowerShell modules

.EXAMPLE
	.\setup-dev-environment.ps1
	Runs full setup with all components

.EXAMPLE
	.\setup-dev-environment.ps1 -SkipWinget
	Runs setup but skips Winget package installation
#>

[CmdletBinding()]
param(
	[switch]$SkipWinget,
	[switch]$SkipWindowsFeatures,
	[switch]$SkipPowerShellModules
)

# Requires elevation
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Step {
	param([string]$Message)
	Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
	param([string]$Message)
	Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warning {
	param([string]$Message)
	Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
	param([string]$Message)
	Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if running as administrator
function Test-Administrator {
	$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
	return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
	Write-ErrorMsg "This script must be run as Administrator!"
	exit 1
}

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Windows 11 Development Environment Setup" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

# Install Winget packages
if (-not $SkipWinget) {
	Write-Step "Installing development tools via Winget..."

	$wingetPackages = @(
		"Git.Git",
		"Microsoft.VisualStudioCode",
		"Microsoft.PowerShell",
		"Microsoft.WindowsTerminal",
		"Docker.DockerDesktop",
		"OpenJS.NodeJS.LTS",
		"Python.Python.3.12",
		"JetBrains.Toolbox",
		"Microsoft.DotNet.SDK.8",
		"7zip.7zip",
		"Google.Chrome",
		"Mozilla.Firefox"
	)

	foreach ($package in $wingetPackages) {
		try {
			Write-Host "  Installing $package..." -ForegroundColor Gray
			winget install --id $package --silent --accept-package-agreements --accept-source-agreements
			Write-Success "Installed $package"
		}
		catch {
			Write-Warning "Failed to install $package: $_"
		}
	}
}

# Enable Windows Features
if (-not $SkipWindowsFeatures) {
	Write-Step "Enabling Windows features for development..."

	$features = @(
		"Microsoft-Windows-Subsystem-Linux",
		"VirtualMachinePlatform",
		"Microsoft-Hyper-V-All",
		"Containers"
	)

	foreach ($feature in $features) {
		try {
			$featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
			if ($featureState -and $featureState.State -ne "Enabled") {
				Write-Host "  Enabling $feature..." -ForegroundColor Gray
				Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -All
				Write-Success "Enabled $feature"
			}
			else {
				Write-Success "$feature already enabled"
			}
		}
		catch {
			Write-Warning "Failed to enable $feature: $_"
		}
	}
}

# Install PowerShell modules
if (-not $SkipPowerShellModules) {
	Write-Step "Installing PowerShell modules..."

	$modules = @(
		"PSReadLine",
		"Posh-Git",
		"Terminal-Icons",
		"Az",
		"PowerShellGet"
	)

	foreach ($module in $modules) {
		try {
			if (-not (Get-Module -ListAvailable -Name $module)) {
				Write-Host "  Installing $module..." -ForegroundColor Gray
				Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
				Write-Success "Installed $module"
			}
			else {
				Write-Success "$module already installed"
			}
		}
		catch {
			Write-Warning "Failed to install $module: $_"
		}
	}
}

# Configure Git
Write-Step "Configuring Git..."
try {
	$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
	if ($gitInstalled) {
		git config --global core.autocrlf true
		git config --global init.defaultBranch main
		git config --global pull.rebase false
		Write-Success "Git configured"
	}
	else {
		Write-Warning "Git not found. Install it first."
	}
}
catch {
	Write-Warning "Failed to configure Git: $_"
}

# Set up environment variables
Write-Step "Configuring environment variables..."
try {
	# Add common development paths to PATH if not already present
	$pathsToAdd = @(
		"$env:USERPROFILE\.dotnet\tools",
		"$env:PROGRAMFILES\Docker\Docker\resources\bin"
	)

	$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
	foreach ($pathToAdd in $pathsToAdd) {
		if ($currentPath -notlike "*$pathToAdd*") {
			[Environment]::SetEnvironmentVariable(
				"Path",
				"$currentPath;$pathToAdd",
				"User"
			)
			Write-Success "Added $pathToAdd to PATH"
		}
	}
}
catch {
	Write-Warning "Failed to configure environment variables: $_"
}

# Create common development directories
Write-Step "Creating development directories..."
$devDirs = @(
	"$env:USERPROFILE\Dev",
	"$env:USERPROFILE\Dev\Projects",
	"$env:USERPROFILE\Dev\Tools",
	"$env:USERPROFILE\Dev\Temp"
)

foreach ($dir in $devDirs) {
	if (-not (Test-Path $dir)) {
		New-Item -Path $dir -ItemType Directory -Force | Out-Null
		Write-Success "Created $dir"
	}
}

# Configure Windows Terminal settings (if installed)
Write-Step "Configuring Windows Terminal..."
$terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettingsPath) {
	Write-Success "Windows Terminal settings found at $terminalSettingsPath"
	Write-Host "  You can customize your terminal settings manually." -ForegroundColor Gray
}
else {
	Write-Warning "Windows Terminal not installed or settings not found"
}

# Install WSL2 distributions
Write-Step "Setting up WSL2..."
try {
	$wslCheck = wsl --status 2>&1
	if ($LASTEXITCODE -eq 0) {
		Write-Success "WSL is installed"
		Write-Host "  To install Ubuntu, run: wsl --install -d Ubuntu" -ForegroundColor Gray
	}
	else {
		Write-Host "  Installing WSL..." -ForegroundColor Gray
		wsl --install --no-distribution
		Write-Success "WSL installed. Reboot required."
	}
}
catch {
	Write-Warning "Failed to configure WSL: $_"
}

# Summary
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Setup Complete!" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Restart your computer to complete Windows features installation" -ForegroundColor Yellow
Write-Host "2. Configure Git with your name and email:" -ForegroundColor Yellow
Write-Host "   git config --global user.name 'Your Name'" -ForegroundColor Gray
Write-Host "   git config --global user.email 'your.email@example.com'" -ForegroundColor Gray
Write-Host "3. Install WSL Ubuntu distribution: wsl --install -d Ubuntu" -ForegroundColor Yellow
Write-Host "4. Configure your PowerShell profile for customizations" -ForegroundColor Yellow
Write-Host "5. Launch Docker Desktop and complete setup" -ForegroundColor Yellow
Write-Host "`nHappy coding! 🚀" -ForegroundColor Green
