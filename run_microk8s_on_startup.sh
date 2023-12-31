#!/bin/bash

# System settings so microk8s runs on startup

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Create the systemd service file
cat <<EOL > /etc/systemd/system/microk8s.service
[Unit]
Description=MicroK8s
Documentation=https://microk8s.io

[Service]
ExecStart=/snap/bin/microk8s.start
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd
systemctl daemon-reload

# Enable and start the MicroK8s service
systemctl enable microk8s
systemctl start microk8s

# Display status
systemctl status microk8s

echo "MicroK8s service has been configured and started."
