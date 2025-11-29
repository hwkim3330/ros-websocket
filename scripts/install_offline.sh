#!/bin/bash
# Offline installer for ROS Web Controller
# Use after running install_dependencies.sh on a machine with internet

set -e

echo "========================================"
echo "ROS Web Controller - Offline Installer"
echo "========================================"

DEPS_DIR="$HOME/ros_web_deps"

if [ ! -d "$DEPS_DIR" ]; then
    echo "[ERROR] Dependencies not found at $DEPS_DIR"
    echo "First run install_dependencies.sh on a machine with internet"
    exit 1
fi

# Install .deb packages
echo "[1/3] Installing ROS2 packages..."
cd "$DEPS_DIR"
sudo dpkg -i *.deb 2>/dev/null || sudo apt-get -f install -y

# Install Python packages
echo "[2/3] Installing Python packages..."
if [ -d "$DEPS_DIR/pip" ]; then
    pip3 install --no-index --find-links="$DEPS_DIR/pip" tornado bson 2>/dev/null || true
fi

# Build ROS package
echo "[3/3] Building ros_web_controller..."
if [ -d "$HOME/ros2_ws/src/ros-websocket" ]; then
    cd "$HOME/ros2_ws"
    source /opt/ros/humble/setup.bash
    colcon build --packages-select ros_web_controller --symlink-install
    echo "source $HOME/ros2_ws/install/setup.bash" >> ~/.bashrc
    source install/setup.bash
    echo "[OK] Build complete!"
else
    echo "[WARN] ros-websocket not found in ~/ros2_ws/src/"
    echo "Clone or copy the repository first"
fi

echo ""
echo "========================================"
echo "Installation complete!"
echo ""
echo "Run with:"
echo "  ros2 launch ros_web_controller web_control.launch.py"
echo "========================================"
