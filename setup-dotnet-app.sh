#!/bin/bash

# Define variables
APP_NAME="uppgift03"
APP_DIR="/opt/$APP_NAME"
SERVICE_FILE="/etc/systemd/system/$APP_NAME.service"

# Step 1: Install .NET Runtime 8.0
echo "Installing .NET Runtime 8.0..."
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y aspnetcore-runtime-8.0

# Step 2: Create application directory
echo "Creating application directory..."
sudo mkdir -p $APP_DIR

# Step 3: Copy your application files to the server
# Assuming you have already uploaded your application files to the server
# Example: Copy the application publish folder to /opt/GithubActionsDemo
# Use scp or other methods to transfer your files.
# Uncomment this and adjust the source path accordingly if needed:
# sudo cp -r /path/to/publish/* $APP_DIR

# Step 4: Create a systemd service file
echo "Creating systemd service for $APP_NAME..."
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=ASP.NET Web App running on Ubuntu

[Service]
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/dotnet $APP_DIR/$APP_NAME.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=$APP_NAME
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment="ASPNETCORE_URLS=http://*:5000"

[Install]
WantedBy=multi-user.target
EOL

# Step 5: Set the correct permissions for the service file
echo "Setting permissions for the service file..."
sudo chmod 644 $SERVICE_FILE
sudo chown root:root $SERVICE_FILE

# Step 6: Reload systemd to apply the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Step 7: Enable and start the service
echo "Enabling and starting the $APP_NAME service..."
sudo systemctl enable $APP_NAME
sudo systemctl start $APP_NAME

# Step 8: Verify the service status
echo "Checking the status of $APP_NAME service..."
sudo systemctl status $APP_NAME
