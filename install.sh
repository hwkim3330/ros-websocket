#!/bin/bash
#
# ROS Web Controller - One-line Installer
# Usage: curl -sL https://raw.githubusercontent.com/hwkim3330/ros-websocket/main/install.sh | bash
#
set -e

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           ROS Web Controller - Installer                   ║"
echo "║           Jetson Orin Nano / ROS2 Humble                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check ROS2
if [ ! -d "/opt/ros/humble" ]; then
    echo "[ERROR] ROS2 Humble not found!"
    echo ""
    echo "Install ROS2 Humble first:"
    echo "  https://docs.ros.org/en/humble/Installation.html"
    echo ""
    exit 1
fi

source /opt/ros/humble/setup.bash
echo "[OK] ROS2 Humble detected"

# Install dependencies
echo ""
echo "[1/4] Installing dependencies..."
sudo apt update -qq
sudo apt install -y -qq ros-humble-rosbridge-server 2>/dev/null || {
    echo "[WARN] rosbridge-server install failed, trying with apt-get..."
    sudo apt-get install -y ros-humble-rosbridge-server
}

# Create workspace
echo ""
echo "[2/4] Setting up workspace..."
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src

# Clone or update
if [ -d "ros-websocket" ]; then
    echo "[INFO] Updating existing repository..."
    cd ros-websocket
    git pull
    cd ..
else
    echo "[INFO] Cloning repository..."
    git clone https://github.com/hwkim3330/ros-websocket.git
fi

# Build
echo ""
echo "[3/4] Building package..."
cd ~/ros2_ws
colcon build --packages-select ros_web_controller --symlink-install

# Setup bashrc
echo ""
echo "[4/4] Configuring environment..."
if ! grep -q "ros2_ws/install/setup.bash" ~/.bashrc; then
    echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
fi

source install/setup.bash

# Get IP
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "  Run:     ros2 launch ros_web_controller web_control.launch.py"
echo ""
echo "  Access:  http://${IP}:8080"
echo "           http://localhost:8080"
echo ""
echo "  (Restart terminal or run: source ~/.bashrc)"
echo ""
