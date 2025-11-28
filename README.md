# ros_web_controller

<p align="center">
  <img width="1912" alt="ROS Web Controller Screenshot" src="https://github.com/user-attachments/assets/cbff4677-40b7-46fa-80c3-b5d9526b223d" />
</p>

<p align="center">
  <strong>Web-based robot controller for ROS2</strong><br>
  Control your robot from any browser with real-time camera streaming and LiDAR visualization
</p>

<p align="center">
  <a href="https://hwkim3330.github.io/ros-websocket/">Live Demo</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#jetson-orin-nano-complete-guide">Jetson Guide</a> •
  <a href="#troubleshooting">Troubleshooting</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ROS2-Humble-blue" alt="ROS2 Humble">
  <img src="https://img.shields.io/badge/Platform-Jetson%20Orin-green" alt="Jetson">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT License">
  <img src="https://img.shields.io/badge/WebSocket-rosbridge-orange" alt="rosbridge">
</p>

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [System Architecture](#system-architecture)
- [Quick Start](#quick-start)
- [Jetson Orin Nano Complete Guide](#jetson-orin-nano-complete-guide)
  - [Prerequisites](#prerequisites)
  - [Step 1: Install ROS2 Humble](#step-1-install-ros2-humble)
  - [Step 2: Install Dependencies](#step-2-install-dependencies)
  - [Step 3: Build Package](#step-3-build-package)
  - [Step 4: Network Setup](#step-4-network-setup)
  - [Step 5: Camera Configuration](#step-5-camera-configuration)
  - [Step 6: LiDAR Configuration](#step-6-lidar-configuration)
  - [Step 7: Autostart Setup](#step-7-autostart-setup-systemd)
- [Usage](#usage)
- [Web UI Features](#web-ui-features)
- [ROS2 Topics](#ros2-topics)
- [Camera Streaming](#camera-streaming)
  - [rosbridge Mode](#rosbridge-mode-default)
  - [MJPEG Mode](#mjpeg-mode-lower-latency)
  - [Performance Comparison](#performance-comparison)
- [Controls](#controls)
- [Package Structure](#package-structure)
- [Troubleshooting](#troubleshooting)
- [Performance Optimization](#performance-optimization)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Features

| Feature | Description |
|---------|-------------|
| **Joystick Control** | Touch/mouse joystick with smooth velocity output |
| **D-Pad Navigation** | Direction buttons for quick movement commands |
| **Keyboard Support** | WASD and Arrow keys for desktop control |
| **Camera Streaming** | Real-time video via rosbridge (Base64) or MJPEG |
| **LiDAR Visualization** | 2D laser scan display with distance indicators |
| **Motor Speed Display** | Left/right motor speed estimation for differential drive |
| **Topic Browser** | Auto-detect and select available ROS2 topics |
| **Mobile PWA** | Add to home screen for app-like experience |
| **Dark Theme** | Modern dark UI optimized for all screen sizes |

---

## Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Platform** | Any ROS2 system | Jetson Orin Nano |
| **ROS2** | Humble Hawksbill | Humble Hawksbill |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| **Python** | 3.10+ | 3.10+ |
| **Browser** | Chrome 80+, Safari 14+ | Latest Chrome/Safari |
| **Network** | WiFi 2.4GHz | WiFi 5GHz / Ethernet |

### Tested Platforms

- ✅ NVIDIA Jetson Orin Nano (JetPack 6.x)
- ✅ NVIDIA Jetson Xavier NX
- ✅ Raspberry Pi 4 (Ubuntu 22.04)
- ✅ x86_64 Desktop/Laptop

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Client Device (Phone/PC)                         │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    Web Browser (Chrome/Safari)                  │   │
│   │                                                                 │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│   │  │   Camera    │  │   LiDAR     │  │      Control Panel      │  │   │
│   │  │   Stream    │  │   Canvas    │  │  Joystick / D-Pad / KB  │  │   │
│   │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │   │
│   │                                                                 │   │
│   │                    ROSLIB.js (WebSocket Client)                 │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
└────────────────────────────────────│─────────────────────────────────────┘
                                     │ WebSocket (ws://ROBOT_IP:9090)
                                     │ HTTP (http://ROBOT_IP:8080)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        Robot (Jetson Orin Nano)                         │
│                                                                         │
│   ┌──────────────────────────┐    ┌──────────────────────────────────┐  │
│   │     web_server.py        │    │        rosbridge_server          │  │
│   │     (HTTP Server)        │    │        (WebSocket Server)        │  │
│   │                          │    │                                  │  │
│   │   • Serves index.html    │    │   • JSON ↔ ROS2 Message          │  │
│   │   • Port: 8080           │    │   • Subscribe/Publish Topics     │  │
│   │   • Static file hosting  │    │   • Port: 9090                   │  │
│   └──────────────────────────┘    └──────────────────────────────────┘  │
│                                                │                         │
│   ┌────────────────────────────────────────────▼────────────────────┐   │
│   │                         ROS2 Humble                             │   │
│   │                                                                 │   │
│   │   Publishers:                    Subscribers:                   │   │
│   │   ┌─────────────────────────┐   ┌─────────────────────────┐     │   │
│   │   │ /cmd_vel               │   │ /scan                   │     │   │
│   │   │ geometry_msgs/Twist    │   │ sensor_msgs/LaserScan   │     │   │
│   │   │ linear.x, angular.z    │   │ ranges[], angle_min/max │     │   │
│   │   └──────────┬──────────────┘   └──────────┬──────────────┘     │   │
│   │              │                             │                     │   │
│   │              ▼                             │                     │   │
│   │   ┌─────────────────────────┐              │                     │   │
│   │   │    Motor Driver Node   │              │                     │   │
│   │   │    (jetbot_ros, etc)   │              │                     │   │
│   │   └─────────────────────────┘              │                     │   │
│   │                                            │                     │   │
│   │   ┌─────────────────────────┐   ┌─────────┴─────────────┐       │   │
│   │   │ /camera/image/compressed│   │    LiDAR Driver      │       │   │
│   │   │ sensor_msgs/            │   │    (rplidar, etc)    │       │   │
│   │   │ CompressedImage         │   └───────────────────────┘       │   │
│   │   └──────────┬──────────────┘                                   │   │
│   │              │                                                   │   │
│   │   ┌──────────▼──────────────┐                                   │   │
│   │   │    Camera Driver Node   │                                   │   │
│   │   │    (usb_cam, v4l2)      │                                   │   │
│   │   └─────────────────────────┘                                   │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│   Hardware:                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│   │   Motors    │  │   Camera    │  │   LiDAR     │  │   WiFi      │   │
│   │   (DC/Servo)│  │   (USB/CSI) │  │   (RPLidar) │  │   Module    │   │
│   └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
[Joystick Touch] → [JavaScript] → [ROSLIB.js] → [WebSocket :9090]
                                                        │
                                                        ▼
                                              [rosbridge_server]
                                                        │
                                                        ▼
                                              [/cmd_vel Topic]
                                                        │
                                                        ▼
                                              [Motor Driver Node]
                                                        │
                                                        ▼
                                                  [Robot Moves]
```

```
[LiDAR Sensor] → [LiDAR Driver] → [/scan Topic] → [rosbridge_server]
                                                          │
                                                          ▼
                                                  [WebSocket :9090]
                                                          │
                                                          ▼
                                               [JavaScript Canvas]
                                                          │
                                                          ▼
                                               [2D Visualization]
```

---

## Quick Start

For users with ROS2 already installed:

```bash
# 1. Clone repository
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

# 2. Install rosbridge
sudo apt update
sudo apt install -y ros-humble-rosbridge-server

# 3. Build
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash

# 4. Launch
ros2 launch ros_web_controller web_control.launch.py

# 5. Open browser: http://ROBOT_IP:8080
```

---

## Jetson Orin Nano Complete Guide

Complete step-by-step guide for setting up on Jetson Orin Nano with JetPack 6.x.

### Prerequisites

Before starting, verify your system:

```bash
# Check JetPack version (should be R36.x for JetPack 6.x)
cat /etc/nv_tegra_release
# Output: # R36 (release), REVISION: 3.0, ...

# Check Ubuntu version (should be 22.04)
lsb_release -a
# Output: Ubuntu 22.04.x LTS

# Check architecture
uname -m
# Output: aarch64

# Check available disk space (minimum 10GB recommended)
df -h /
# Ensure at least 10GB free

# Check memory
free -h
# Jetson Orin Nano has 8GB RAM

# Check if swap exists (important for building)
swapon --show
```

If you need more swap space:

```bash
# Create 4GB swap file
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Step 1: Install ROS2 Humble

Complete ROS2 Humble installation on Jetson:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Set UTF-8 locale
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Install required tools
sudo apt install -y software-properties-common curl gnupg lsb-release

# Add universe repository
sudo add-apt-repository universe

# Add ROS2 GPG key
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Add ROS2 repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Update package index
sudo apt update

# Install ROS2 Humble (base version for embedded systems)
sudo apt install -y ros-humble-ros-base

# Install development tools
sudo apt install -y \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-pip \
    build-essential

# Initialize rosdep (first time only)
sudo rosdep init || true
rosdep update

# Add ROS2 to bashrc
echo "" >> ~/.bashrc
echo "# ROS2 Humble" >> ~/.bashrc
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Verify installation
ros2 --version
# Output: ros2 version x.x.x
```

### Step 2: Install Dependencies

Install all required ROS2 packages:

```bash
# Core dependencies (required)
sudo apt install -y \
    ros-humble-rosbridge-server \
    ros-humble-rosbridge-suite

# Image transport (required for camera)
sudo apt install -y \
    ros-humble-cv-bridge \
    ros-humble-image-transport \
    ros-humble-image-transport-plugins \
    ros-humble-compressed-image-transport

# Camera drivers (choose based on your camera)
sudo apt install -y \
    ros-humble-usb-cam \
    ros-humble-v4l2-camera

# LiDAR support (optional, for RPLidar)
sudo apt install -y ros-humble-rplidar-ros || true

# MJPEG streaming server (optional, for lower latency)
sudo apt install -y ros-humble-web-video-server || true

# Python dependencies
pip3 install --user setuptools wheel
```

### Step 3: Build Package

Create workspace and build the package:

```bash
# Create ROS2 workspace
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src

# Clone this repository
git clone https://github.com/hwkim3330/ros-websocket.git

# Navigate to workspace root
cd ~/ros2_ws

# Install dependencies via rosdep
rosdep install --from-paths src --ignore-src -r -y

# Build with optimizations for Jetson
# Use sequential executor to prevent memory issues
colcon build \
    --packages-select ros_web_controller \
    --symlink-install \
    --executor sequential \
    --cmake-args -DCMAKE_BUILD_TYPE=Release

# Source the workspace
source install/setup.bash

# Add workspace to bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Verify installation
ros2 pkg list | grep ros_web_controller
# Output: ros_web_controller
```

### Step 4: Network Setup

Configure network for web access:

```bash
# Check current IP address
hostname -I
# Note: First IP is usually your WiFi/Ethernet address

# Check network interfaces
ip link show
# Common: wlan0 (WiFi), eth0 (Ethernet)

# Configure firewall (if ufw is enabled)
sudo ufw status
# If active, allow required ports:
sudo ufw allow 8080/tcp comment "ROS Web Controller HTTP"
sudo ufw allow 9090/tcp comment "rosbridge WebSocket"
sudo ufw reload

# Test port availability
ss -tlnp | grep -E '8080|9090'
# Should show nothing if ports are free

# For WiFi hotspot mode (robot as access point)
sudo nmcli device wifi hotspot \
    ifname wlan0 \
    ssid "MyRobot" \
    password "robot12345"
# Connect to "MyRobot" network, access http://10.42.0.1:8080

# Static IP configuration (optional, recommended)
sudo nmcli connection modify "Wired connection 1" \
    ipv4.addresses "192.168.1.100/24" \
    ipv4.gateway "192.168.1.1" \
    ipv4.dns "8.8.8.8" \
    ipv4.method "manual"
sudo nmcli connection up "Wired connection 1"
```

### Step 5: Camera Configuration

Set up camera for streaming:

```bash
# Check available video devices
ls -la /dev/video*
v4l2-ctl --list-devices

# Check camera capabilities
v4l2-ctl -d /dev/video0 --list-formats-ext

# Set video group permission (required for camera access)
sudo usermod -aG video $USER
# Log out and log back in for group changes to take effect

# Test USB camera with usb_cam
ros2 run usb_cam usb_cam_node_exe --ros-args \
    -p video_device:=/dev/video0 \
    -p image_width:=640 \
    -p image_height:=480 \
    -p framerate:=15.0 \
    -p pixel_format:=yuyv

# Test CSI camera (NVIDIA IMX219, etc)
ros2 run v4l2_camera v4l2_camera_node --ros-args \
    -p video_device:=/dev/video0 \
    -p image_size:="[640, 480]" \
    -p camera_frame_id:=camera_optical_frame

# Check if camera topic is publishing
ros2 topic list | grep image
ros2 topic hz /image_raw

# Compress images for web streaming (if only raw available)
ros2 run image_transport republish raw compressed \
    --ros-args \
    -r in:=/image_raw \
    -r out/compressed:=/image_raw/compressed
```

#### Camera Launch File Example

Create a custom launch file for your camera setup:

```python
# ~/ros2_ws/src/my_robot_bringup/launch/camera.launch.py
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        # USB Camera
        Node(
            package='usb_cam',
            executable='usb_cam_node_exe',
            name='camera',
            parameters=[{
                'video_device': '/dev/video0',
                'image_width': 640,
                'image_height': 480,
                'framerate': 15.0,
                'pixel_format': 'yuyv',
                'camera_frame_id': 'camera_optical_frame',
            }],
            remappings=[
                ('image_raw', '/camera/image_raw'),
                ('image_raw/compressed', '/camera/image/compressed'),
            ]
        ),
    ])
```

### Step 6: LiDAR Configuration

Set up LiDAR sensor (optional):

```bash
# For RPLidar A1/A2/A3
# Check USB connection
ls -la /dev/ttyUSB*

# Set permissions for serial port
sudo chmod 666 /dev/ttyUSB0
# Or add udev rule for permanent fix:
echo 'KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", SYMLINK+="rplidar"' | sudo tee /etc/udev/rules.d/99-rplidar.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Run RPLidar node
ros2 launch rplidar_ros rplidar_a1_launch.py

# For other LiDAR sensors, install appropriate driver:
# - YDLidar: ros-humble-ydlidar-ros2-driver
# - Hokuyo: ros-humble-urg-node
# - Livox: ros-humble-livox-ros2-driver

# Verify LiDAR topic
ros2 topic list | grep scan
ros2 topic echo /scan --once
```

### Step 7: Autostart Setup (systemd)

Configure automatic startup on boot:

```bash
# Create systemd service file
sudo tee /etc/systemd/system/ros_web_controller.service << 'EOF'
[Unit]
Description=ROS2 Web Controller
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=USER_PLACEHOLDER
Group=USER_PLACEHOLDER
Environment="HOME=/home/USER_PLACEHOLDER"
Environment="ROS_DOMAIN_ID=0"
Environment="RMW_IMPLEMENTATION=rmw_fastrtps_cpp"
Environment="ROS_LOCALHOST_ONLY=0"

ExecStart=/bin/bash -c '\
    source /opt/ros/humble/setup.bash && \
    source /home/USER_PLACEHOLDER/ros2_ws/install/setup.bash && \
    ros2 launch ros_web_controller web_control.launch.py'

Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Replace placeholder with actual username
sudo sed -i "s/USER_PLACEHOLDER/$USER/g" /etc/systemd/system/ros_web_controller.service

# Reload systemd
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable ros_web_controller

# Start service now
sudo systemctl start ros_web_controller

# Check status
sudo systemctl status ros_web_controller

# View logs
journalctl -u ros_web_controller -f

# Useful commands
sudo systemctl stop ros_web_controller     # Stop service
sudo systemctl restart ros_web_controller  # Restart service
sudo systemctl disable ros_web_controller  # Disable autostart
```

#### Complete Robot Launch File

For a complete robot setup, create a combined launch file:

```python
# ~/ros2_ws/src/my_robot_bringup/launch/robot.launch.py
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os

def generate_launch_description():
    # Get package directories
    web_controller_share = get_package_share_directory('ros_web_controller')

    return LaunchDescription([
        # Web Controller
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource(
                os.path.join(web_controller_share, 'launch', 'web_control.launch.py')
            )
        ),

        # Camera Node
        Node(
            package='usb_cam',
            executable='usb_cam_node_exe',
            name='camera',
            parameters=[{
                'video_device': '/dev/video0',
                'image_width': 640,
                'image_height': 480,
                'framerate': 15.0,
            }]
        ),

        # LiDAR Node (optional)
        Node(
            package='rplidar_ros',
            executable='rplidar_node',
            name='rplidar',
            parameters=[{
                'serial_port': '/dev/ttyUSB0',
                'frame_id': 'laser_frame',
            }]
        ),

        # Your motor driver node
        # Node(
        #     package='your_motor_driver',
        #     executable='motor_node',
        #     name='motors',
        # ),
    ])
```

---

## Usage

### Basic Launch

```bash
# Source ROS2 environment
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash

# Launch web controller only
ros2 launch ros_web_controller web_control.launch.py

# Launch with custom ports
ros2 launch ros_web_controller web_control.launch.py \
    web_port:=8080 \
    rosbridge_port:=9090
```

### Access Web Interface

1. Find robot IP: `hostname -I`
2. Open browser: `http://ROBOT_IP:8080`
3. Enter robot IP in the connection field (auto-filled if accessing via IP)
4. Click "Connect"

#### Mobile Access (iOS/Android)

1. Connect phone to same network as robot
2. Open Safari/Chrome
3. Navigate to `http://ROBOT_IP:8080`
4. **iOS**: Share → "Add to Home Screen"
5. **Android**: Menu → "Add to Home Screen"

### Launch Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `web_port` | `8080` | HTTP server port for web UI |
| `rosbridge_port` | `9090` | WebSocket port for rosbridge |

---

## Web UI Features

### Connection Panel
- IP address input with auto-detection
- Port configuration
- Connection status indicator (green = connected)

### Camera Panel
- Real-time video stream display
- Stream mode selector (rosbridge/MJPEG)
- Topic input for camera topic selection
- FPS counter

### LiDAR Panel
- 2D polar visualization
- Distance range display
- Point count indicator
- Topic selection

### Control Panel
- **Joystick**: Drag anywhere in circular area
- **Velocity Display**: Real-time linear/angular velocity
- **Motor Bars**: Left/right motor speed estimation

### Speed Settings
- Linear speed slider (0.1 - 2.0 m/s)
- Angular speed slider (0.1 - 3.0 rad/s)

### D-Pad
- 8-direction movement buttons
- Stop button (emergency stop)
- Rotation buttons

### Topics Panel
- Auto-refresh topic list
- Click to select camera/LiDAR topics
- Color coding by topic type

---

## ROS2 Topics

### Published Topics (Web → Robot)

| Topic | Type | Description | Rate |
|-------|------|-------------|------|
| `/cmd_vel` | `geometry_msgs/Twist` | Velocity command | 20 Hz |

**Twist Message Structure:**
```
geometry_msgs/Twist:
  linear:
    x: float64  # Forward/backward velocity (m/s)
    y: 0.0      # Not used (differential drive)
    z: 0.0      # Not used
  angular:
    x: 0.0      # Not used
    y: 0.0      # Not used
    z: float64  # Rotation velocity (rad/s)
```

### Subscribed Topics (Robot → Web)

| Topic | Type | Description | Recommended Rate |
|-------|------|-------------|------------------|
| `/scan` | `sensor_msgs/LaserScan` | LiDAR scan | 5-10 Hz |
| `/camera/image/compressed` | `sensor_msgs/CompressedImage` | Camera image | 10-15 Hz |

**LaserScan Message Structure:**
```
sensor_msgs/LaserScan:
  header: std_msgs/Header
  angle_min: float32      # Start angle (rad)
  angle_max: float32      # End angle (rad)
  angle_increment: float32
  range_min: float32      # Minimum range (m)
  range_max: float32      # Maximum range (m)
  ranges: float32[]       # Distance array
```

### Topic Customization

Topics can be changed in the web UI:
1. Connect to robot
2. Click "Refresh" in Topics panel
3. Click on a topic to select it for Camera or LiDAR

---

## Camera Streaming

### rosbridge Mode (Default)

Uses rosbridge WebSocket to stream images encoded in Base64.

**Pros:**
- No additional setup required
- Works with any compressed image topic
- Firewall-friendly (single WebSocket connection)

**Cons:**
- ~33% bandwidth overhead from Base64 encoding
- Higher latency at high resolutions

**Best for:**
- Low resolution (320x240, 640x480)
- Bandwidth-limited networks
- Simple setup requirements

### MJPEG Mode (Lower Latency)

Uses `web_video_server` for direct HTTP MJPEG streaming.

**Setup:**
```bash
# Install web_video_server
sudo apt install ros-humble-web-video-server

# Run (in addition to web_controller)
ros2 run web_video_server web_video_server --ros-args -p port:=8080
```

**Pros:**
- Native JPEG streaming, no Base64 overhead
- Lower latency
- Browser-native video handling

**Cons:**
- Requires additional package
- Additional port (or share port 8080)
- Separate HTTP connection

**Best for:**
- High resolution (720p, 1080p)
- Real-time control applications
- Low-latency requirements

### Performance Comparison

| Mode | Resolution | Bandwidth | Latency | CPU Usage |
|------|------------|-----------|---------|-----------|
| rosbridge | 320x240 | ~150 KB/s | ~100ms | Low |
| rosbridge | 640x480 | ~500 KB/s | ~150ms | Medium |
| MJPEG | 320x240 | ~100 KB/s | ~50ms | Low |
| MJPEG | 640x480 | ~350 KB/s | ~80ms | Medium |
| MJPEG | 1280x720 | ~800 KB/s | ~100ms | High |

**Recommendation:**
- Use **rosbridge** for 640x480 or lower
- Use **MJPEG** for 720p or higher
- For real-time control, keep resolution low and prioritize latency

---

## Controls

### Keyboard Controls

| Key | Action | Velocity |
|-----|--------|----------|
| `W` / `↑` | Forward | +linear.x |
| `S` / `↓` | Backward | -linear.x |
| `A` / `←` | Turn Left | +angular.z |
| `D` / `→` | Turn Right | -angular.z |
| `Space` | Emergency Stop | All zero |

Multiple keys can be pressed simultaneously for combined movement.

### Touch/Mouse Controls

**Joystick:**
- Click/touch anywhere in joystick area
- Drag to control velocity
- Release to stop

**D-Pad:**
- Tap and hold for continuous movement
- Release to stop

### Velocity Calculation

For differential drive robots:
```
left_wheel  = linear.x - (angular.z * wheel_base / 2)
right_wheel = linear.x + (angular.z * wheel_base / 2)
```

Default wheel base: 0.14m (adjust in web/index.html if needed)

---

## Package Structure

```
ros-websocket/
├── package.xml                      # ROS2 package manifest
├── setup.py                         # Python package setup
├── setup.cfg                        # Setup configuration
├── README.md                        # This file
│
├── launch/
│   ├── web_control.launch.py        # Main launch file
│   └── rosbridge_websocket.launch.xml  # rosbridge config
│
├── ros_web_controller/              # Python package
│   ├── __init__.py
│   └── web_server.py                # HTTP server node
│
├── web/
│   └── index.html                   # Web UI (served to clients)
│
├── docs/
│   └── index.html                   # GitHub Pages demo
│
└── resource/
    └── ros_web_controller           # ament resource marker
```

---

## Troubleshooting

### Connection Issues

#### Cannot access web page

```bash
# 1. Check if nodes are running
ros2 node list
# Should show: /web_server, /rosbridge_websocket

# 2. Check ports
ss -tlnp | grep -E '8080|9090'
# Should show both ports listening

# 3. Check firewall
sudo ufw status
# If active, ensure 8080 and 9090 are allowed

# 4. Test local access
curl http://localhost:8080
# Should return HTML content

# 5. Check network connectivity
ping ROBOT_IP  # From client device
```

#### WebSocket connection failed

```bash
# Check browser console (F12 → Console)
# Common errors:

# "WebSocket connection failed"
# → Wrong IP or port 9090 blocked

# "Connection refused"
# → rosbridge not running

# Test WebSocket manually:
wscat -c ws://ROBOT_IP:9090
# Should connect without error
```

### Camera Issues

#### No camera image

```bash
# 1. Check camera topic exists
ros2 topic list | grep -i image

# 2. Check if publishing
ros2 topic hz /camera/image/compressed
# Should show non-zero Hz

# 3. Check message content
ros2 topic echo /camera/image/compressed --once
# Should show Base64 data

# 4. Verify camera device
ls /dev/video*
v4l2-ctl --list-devices

# 5. Test camera directly
ros2 run usb_cam usb_cam_node_exe
# Check for errors
```

#### Camera permission denied

```bash
# Add user to video group
sudo usermod -aG video $USER

# Log out and log back in
# Or run: newgrp video

# Verify
groups
# Should include 'video'
```

### LiDAR Issues

#### No LiDAR visualization

```bash
# 1. Check scan topic
ros2 topic list | grep scan

# 2. Check data
ros2 topic echo /scan --once
# Should show ranges array

# 3. Check message type
ros2 topic info /scan
# Should be: sensor_msgs/msg/LaserScan

# 4. Check serial port
ls /dev/ttyUSB*
sudo chmod 666 /dev/ttyUSB0
```

### Motor Control Issues

#### cmd_vel not working

```bash
# 1. Check topic is being published
ros2 topic echo /cmd_vel
# Move joystick, should see values change

# 2. Check subscribers
ros2 topic info /cmd_vel
# Should show at least 1 subscriber (your motor driver)

# 3. Manual test
ros2 topic pub /cmd_vel geometry_msgs/Twist \
    "{linear: {x: 0.1}, angular: {z: 0.0}}" -r 10

# 4. Check motor driver node
ros2 node list
ros2 node info /YOUR_MOTOR_NODE
```

### Jetson-Specific Issues

#### Out of memory during build

```bash
# Use sequential build
colcon build --executor sequential

# Or add swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### ROS2 not found after reboot

```bash
# Check bashrc
cat ~/.bashrc | grep -E "ros|ROS"

# Should have:
# source /opt/ros/humble/setup.bash
# source ~/ros2_ws/install/setup.bash

# If missing, add them:
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```

#### Slow performance

```bash
# Reduce camera resolution
-p image_width:=320 -p image_height:=240

# Reduce framerate
-p framerate:=10.0

# Monitor CPU/GPU usage
tegrastats
```

---

## Performance Optimization

### For Low Latency Control

1. **Reduce camera resolution**: 320x240 or 640x480 maximum
2. **Lower framerate**: 10-15 fps is sufficient for control
3. **Use compressed images**: sensor_msgs/CompressedImage
4. **MJPEG for high-res**: Use web_video_server for 720p+
5. **Wired connection**: Ethernet has lower latency than WiFi
6. **5GHz WiFi**: Less interference than 2.4GHz

### For Bandwidth-Limited Networks

```bash
# Camera settings for low bandwidth
ros2 run usb_cam usb_cam_node_exe --ros-args \
    -p image_width:=320 \
    -p image_height:=240 \
    -p framerate:=10.0 \
    -p jpeg_quality:=50

# Throttle topics
ros2 run topic_tools throttle messages /camera/image/compressed 5.0
```

### For Jetson Power Efficiency

```bash
# Use 15W mode for balance of performance/power
sudo nvpmodel -m 1

# Or max performance
sudo nvpmodel -m 0
sudo jetson_clocks
```

---

## Dependencies

### Required

| Package | Description |
|---------|-------------|
| `rosbridge_server` | WebSocket ↔ ROS2 bridge |
| `rclpy` | ROS2 Python client library |
| `sensor_msgs` | Standard sensor message types |
| `geometry_msgs` | Standard geometry message types |

### Optional

| Package | Description |
|---------|-------------|
| `cv_bridge` | OpenCV ↔ ROS image conversion |
| `image_transport` | Image transport plugins |
| `web_video_server` | HTTP MJPEG streaming |
| `usb_cam` | USB camera driver |
| `v4l2_camera` | V4L2 camera driver |
| `rplidar_ros` | RPLidar driver |

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [rosbridge_suite](https://github.com/RobotWebTools/rosbridge_suite) - WebSocket bridge for ROS
- [ROSLIB.js](https://github.com/RobotWebTools/roslibjs) - JavaScript library for ROS
- [NVIDIA Jetson](https://developer.nvidia.com/embedded-computing) - Edge AI platform
