#!/usr/bin/env bash

#
# Ubuntu Development Environment Setup Script
# Automates the installation and configuration of development tools on Ubuntu
#

set -e  # Exit on error

# Color output functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_step() {
	echo -e "\n${CYAN}[STEP]${NC} $1"
}

print_success() {
	echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
	print_error "Please do not run this script as root. It will use sudo when needed."
	exit 1
fi

echo -e "${MAGENTA}========================================"
echo "Ubuntu Development Environment Setup"
echo -e "========================================${NC}"

# Update system
print_step "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y
print_success "System updated"

# Install essential build tools
print_step "Installing essential build tools..."
sudo apt-get install -y \
	build-essential \
	software-properties-common \
	apt-transport-https \
	ca-certificates \
	curl \
	wget \
	gnupg \
	lsb-release \
	git \
	vim \
	htop \
	tree \
	jq \
	unzip \
	zip \
	net-tools
print_success "Essential tools installed"

# Install Git
print_step "Configuring Git..."
if command -v git &> /dev/null; then
	git config --global core.autocrlf input
	git config --global init.defaultBranch main
	git config --global pull.rebase false
	print_success "Git configured"
	#git config --global user.name 'u'
	#git config --global user.email '@gmail.com'
	print_warning "Configure git global username and email"
else
	print_warning "Git not found"
fi

# Install Docker
print_step "Installing Docker..."
if ! command -v docker &> /dev/null; then
	# Add Docker's official GPG key
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg

	# Set up the repository
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# Install Docker Engine
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Add current user to docker group
	sudo usermod -aG docker $USER
	print_success "Docker installed"
	print_warning "You need to log out and back in for Docker group membership to take effect"
else
	print_success "Docker already installed"
fi

# Install Docker Compose standalone (in addition to plugin)
print_step "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
	DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
	sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	print_success "Docker Compose installed"
else
	print_success "Docker Compose already installed"
fi

# Install Node.js (LTS version via NodeSource)
print_step "Installing Node.js..."
if ! command -v node &> /dev/null; then
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	sudo apt-get install -y nodejs
	print_success "Node.js installed: $(node --version)"
else
	print_success "Node.js already installed: $(node --version)"
fi

# Install Python3 and pip
print_step "Installing Python3 and pip..."
sudo apt-get install -y python3 python3-pip python3-venv
print_success "Python3 installed: $(python3 --version)"

# Install .NET SDK
print_step "Installing .NET SDK..."
if ! command -v dotnet &> /dev/null; then
	wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	sudo dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	sudo apt-get update
	sudo apt-get install -y dotnet-sdk-8.0
	print_success ".NET SDK installed"
else
	print_success ".NET SDK already installed"
fi

# Install VS Code
print_step "Installing Visual Studio Code..."
if ! command -v code &> /dev/null; then
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	sudo apt-get update
	sudo apt-get install -y code
	print_success "VS Code installed"
else
	print_success "VS Code already installed"
fi

# Install AWS CLI
print_step "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -q awscliv2.zip
	sudo ./aws/install
	rm -rf aws awscliv2.zip
	print_success "AWS CLI installed"
else
	print_success "AWS CLI already installed"
fi

# Install Azure CLI
print_step "Installing Azure CLI..."
if ! command -v az &> /dev/null; then
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
	print_success "Azure CLI installed"
else
	print_success "Azure CLI already installed"
fi

# Install kubectl
print_step "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	rm kubectl
	print_success "kubectl installed"
else
	print_success "kubectl already installed"
fi

# Install Terraform
print_step "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt-get update
	sudo apt-get install -y terraform
	print_success "Terraform installed"
else
	print_success "Terraform already installed"
fi

# Install GitHub CLI
print_step "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
	type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install -y gh
	print_success "GitHub CLI installed"
else
	print_success "GitHub CLI already installed"
fi

# Install GitHub Copilot CLI
print_step "Installing GitHub Copilot CLI..."
if command -v gh &> /dev/null; then
	gh extension install github/gh-copilot 2>/dev/null || gh extension upgrade gh-copilot
	print_success "GitHub Copilot CLI installed"
else
	print_warning "GitHub CLI not found, skipping Copilot CLI installation"
fi

# Create common development directories
print_step "Creating development directories..."
mkdir -p ~/dev
mkdir -p ~/dev/projects
mkdir -p ~/dev/tools
mkdir -p ~/dev/temp
print_success "Development directories created"

# Set up shell aliases
print_step "Setting up shell aliases..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIASES_FILE="${SCRIPT_DIR}/../common-aliases.sh"

if [ -f "$ALIASES_FILE" ]; then
	# Add source line to .bashrc if not already present
	if ! grep -q "common-aliases.sh" ~/.bashrc; then
		echo "" >> ~/.bashrc
		echo "# Source common aliases" >> ~/.bashrc
		echo "if [ -f \"$ALIASES_FILE\" ]; then" >> ~/.bashrc
		echo "    source \"$ALIASES_FILE\"" >> ~/.bashrc
		echo "fi" >> ~/.bashrc
		print_success "Aliases added to .bashrc"
	else
		print_success "Aliases already in .bashrc"
	fi
else
	print_warning "common-aliases.sh not found at $ALIASES_FILE"
fi

# Clean up
print_step "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
print_success "Cleanup complete"

# Summary
echo -e "\n${MAGENTA}========================================"
echo "Setup Complete!"
echo -e "========================================${NC}"
echo -e "\n${CYAN}Next steps:${NC}"
echo -e "${YELLOW}1.${NC} Log out and back in for Docker group membership to take effect"
echo -e "${YELLOW}2.${NC} Configure Git with your name and email:"
echo -e "   ${BLUE}git config --global user.name 'Your Name'${NC}"
echo -e "   ${BLUE}git config --global user.email 'your.email@example.com'${NC}"
echo -e "${YELLOW}3.${NC} Reload your shell to use the new aliases:"
echo -e "   ${BLUE}source ~/.bashrc${NC}"
echo -e "${YELLOW}4.${NC} Configure cloud CLIs if needed:"
echo -e "   ${BLUE}aws configure${NC}"
echo -e "   ${BLUE}az login${NC}"
echo -e "${YELLOW}5.${NC} Authenticate GitHub CLI:"
echo -e "   ${BLUE}gh auth login${NC}"
echo -e "\n${GREEN}Happy coding! 🚀${NC}"
