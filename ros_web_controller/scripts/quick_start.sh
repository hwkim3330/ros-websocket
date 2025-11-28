#!/bin/bash
# Quick start script for ROS Web Controller
# Run this on the robot (Jetson)

set -e

echo "==================================="
echo "ROS Web Controller Quick Start"
echo "==================================="

# Check ROS2
if ! command -v ros2 &> /dev/null; then
    echo "ERROR: ROS2 not found. Please source your ROS2 setup."
    echo "  source /opt/ros/humble/setup.bash"
    exit 1
fi

# Check rosbridge
if ! ros2 pkg list | grep -q rosbridge_server; then
    echo "Installing rosbridge_server..."
    sudo apt update
    sudo apt install -y ros-${ROS_DISTRO}-rosbridge-server
fi

# Get IP
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "Starting servers..."
echo "  Web Server: http://${IP}:8080"
echo "  WebSocket:  ws://${IP}:9090"
echo ""
echo "Press Ctrl+C to stop"
echo "==================================="

# Run launch file
ros2 launch ros_web_controller web_control.launch.py
