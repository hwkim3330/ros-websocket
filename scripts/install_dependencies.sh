#!/bin/bash
# Offline dependency installer for ROS Web Controller
# Run this BEFORE going offline to download all required packages

set -e

echo "========================================"
echo "ROS Web Controller - Dependency Installer"
echo "========================================"

# Check if running on Jetson
if [ -f /etc/nv_tegra_release ]; then
    echo "[INFO] Detected Jetson platform"
    PLATFORM="jetson"
else
    echo "[INFO] Detected standard Linux platform"
    PLATFORM="linux"
fi

# Check ROS2 installation
if [ -d "/opt/ros/humble" ]; then
    echo "[OK] ROS2 Humble found"
    source /opt/ros/humble/setup.bash
else
    echo "[ERROR] ROS2 Humble not found!"
    echo "Install ROS2 Humble first:"
    echo "  https://docs.ros.org/en/humble/Installation.html"
    exit 1
fi

# Create download directory
DOWNLOAD_DIR="$HOME/ros_web_deps"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo ""
echo "[1/4] Downloading rosbridge_server packages..."
sudo apt update
apt-get download \
    ros-humble-rosbridge-server \
    ros-humble-rosbridge-library \
    ros-humble-rosbridge-msgs \
    ros-humble-rosapi \
    ros-humble-rosapi-msgs \
    2>/dev/null || echo "[WARN] Some packages may already be installed"

echo ""
echo "[2/4] Downloading Python dependencies..."
pip3 download -d "$DOWNLOAD_DIR/pip" \
    tornado \
    bson \
    pymongo \
    autobahn \
    twisted \
    2>/dev/null || true

echo ""
echo "[3/4] Downloading camera packages (optional)..."
apt-get download \
    ros-humble-usb-cam \
    ros-humble-v4l2-camera \
    ros-humble-image-transport \
    ros-humble-compressed-image-transport \
    2>/dev/null || echo "[INFO] Camera packages - some may not be available"

echo ""
echo "[4/4] Downloading web_video_server (optional, for MJPEG)..."
apt-get download \
    ros-humble-web-video-server \
    2>/dev/null || echo "[INFO] web_video_server may need to be built from source"

echo ""
echo "========================================"
echo "Download complete!"
echo "Packages saved to: $DOWNLOAD_DIR"
echo ""
echo "To install offline, copy this folder to the target machine and run:"
echo "  cd $DOWNLOAD_DIR"
echo "  sudo dpkg -i *.deb"
echo "  pip3 install --no-index --find-links=pip/ tornado bson"
echo "========================================"
