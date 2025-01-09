#!/bin/bash

# Update package list
sudo apt update

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker is already installed."
fi

# Install necessary tools
sudo apt install -y wget unzip

# Download and unzip the package
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip -O openledger-node.zip
unzip openledger-node.zip

# Install the .deb package
sudo dpkg -i openledger-node-1.0.0.deb

# Get the current user's username from the $USER environment variable
MY_USER=$USER

# Check if the username is empty or unset
if [ -z "$MY_USER" ]; then
    echo "Error: \$USER environment variable is not set."
    exit 1
fi

# Add the user to the docker group
sudo usermod -aG docker "$MY_USER"

# Update permissions for the Docker socket
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

# Check if ufw is installed and active
if command -v ufw &> /dev/null; then
    echo "Checking ufw status..."
    UFW_STATUS=$(sudo ufw status | grep -i "Status: active")
    if [ -n "$UFW_STATUS" ]; then
        echo "ufw is active. Adding rules for ports 5555, 8000, and 8080..."
        sudo ufw allow 5555/tcp
        sudo ufw allow 8000/tcp
        sudo ufw allow 8080/tcp
        echo "Firewall rules added successfully."
    else
        echo "ufw is installed but not active. Skipping rule addition."
    fi
else
    echo "ufw is not installed. Skipping firewall rule configuration."
fi

echo "OpenLedger successfully installed!"
echo "Press Enter to continue..."
read -r
newgrp docker
