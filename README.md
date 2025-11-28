# ros_web_controller

<img width="1912" height="970" alt="image" src="https://github.com/user-attachments/assets/cbff4677-40b7-46fa-80c3-b5d9526b223d" />

A web-based robot controller for ROS2. Control your robot from any browser with real-time camera streaming and LiDAR visualization.

**[Live Demo](https://hwkim3330.github.io/ros-websocket/)** (UI preview only)

## Features

- **Joystick Control** - Touch/mouse joystick with smooth velocity control
- **D-Pad & Keyboard** - WASD/Arrow keys support
- **Camera Streaming** - rosbridge (Base64) or MJPEG mode
- **LiDAR Visualization** - Real-time 2D scan display
- **Motor Speed Display** - Differential drive estimation
- **Topic Browser** - Auto-detect available topics
- **Mobile Ready** - PWA support, add to home screen

## Requirements

| Component | Version |
|-----------|---------|
| Platform | Jetson Orin Nano / any ROS2 system |
| ROS2 | Humble Hawksbill |
| Ubuntu | 22.04 LTS |
| Python | 3.10+ |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Client (Phone/PC)                           │
│                                                                 │
│    Safari / Chrome Browser                                      │
│    http://ROBOT_IP:8080                                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │ WiFi / LAN
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Robot (Jetson / PC)                           │
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────────────────────┐│
│  │ web_server.py    │      │     rosbridge_server             ││
│  │ (HTTP :8080)     │      │     (WebSocket :9090)            ││
│  │                  │      │                                  ││
│  │ Serves index.html│      │  JSON ↔ ROS2 message bridge      ││
│  └──────────────────┘      └──────────────┬───────────────────┘│
│                                           │                     │
│  ┌────────────────────────────────────────▼───────────────────┐│
│  │                       ROS2 Humble                          ││
│  │                                                            ││
│  │   /cmd_vel ─────────────────▶ Motor Driver                 ││
│  │   (geometry_msgs/Twist)                                    ││
│  │                                                            ││
│  │   /scan ◀─────────────────── LiDAR Sensor                  ││
│  │   (sensor_msgs/LaserScan)                                  ││
│  │                                                            ││
│  │   /camera/image/compressed ◀─ Camera                       ││
│  │   (sensor_msgs/CompressedImage)                            ││
│  └────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Installation

### Quick Install (Any ROS2 System)

```bash
# 1. Clone to ROS2 workspace
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

# 2. Install dependencies
sudo apt update
sudo apt install -y ros-humble-rosbridge-server

# 3. Build
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash

# 4. (Optional) Add to bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```

---

## Jetson Orin Nano Installation Guide

Jetson Orin Nano specific setup guide for JetPack 6.x with ROS2 Humble.

### Prerequisites Check

```bash
# Check JetPack version
cat /etc/nv_tegra_release
# Expected: # R36 (release), REVISION: x.x

# Check Ubuntu version
lsb_release -a
# Expected: Ubuntu 22.04 LTS

# Check available disk space (need ~5GB for ROS2)
df -h /
```

### Step 1: Install ROS2 Humble on Jetson

```bash
# Set locale
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add ROS2 apt repository
sudo apt install software-properties-common
sudo add-apt-repository universe
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2 Humble
sudo apt update
sudo apt install ros-humble-ros-base python3-colcon-common-extensions -y

# Source ROS2
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### Step 2: Install Dependencies

```bash
# Core dependencies
sudo apt install -y \
    ros-humble-rosbridge-server \
    ros-humble-cv-bridge \
    ros-humble-image-transport \
    python3-pip

# Optional: Camera packages
sudo apt install -y \
    ros-humble-usb-cam \
    ros-humble-v4l2-camera \
    ros-humble-image-transport-plugins

# Optional: MJPEG server for lower latency
sudo apt install -y ros-humble-web-video-server
```

### Step 3: Create Workspace and Build

```bash
# Create workspace if not exists
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src

# Clone this package
git clone https://github.com/hwkim3330/ros-websocket.git

# Build
cd ~/ros2_ws
colcon build --packages-select ros_web_controller --symlink-install

# Source workspace
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### Step 4: Network Configuration

```bash
# Check Jetson IP
hostname -I

# Open required ports
sudo ufw allow 8080/tcp   # Web server
sudo ufw allow 9090/tcp   # WebSocket

# For WiFi hotspot mode (optional)
sudo nmcli device wifi hotspot ssid "JetBot" password "password123"
```

### Step 5: Test Run

```bash
# Terminal 1: Launch web controller
ros2 launch ros_web_controller web_control.launch.py

# Terminal 2: Test camera (if using usb_cam)
ros2 run usb_cam usb_cam_node_exe --ros-args -p video_device:=/dev/video0

# Terminal 3: Check topics
ros2 topic list
```

### Autostart on Boot (systemd)

```bash
# Create service file
sudo tee /etc/systemd/system/ros_web_controller.service << 'EOF'
[Unit]
Description=ROS Web Controller
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
Environment="ROS_DOMAIN_ID=0"
ExecStart=/bin/bash -c 'source /opt/ros/humble/setup.bash && source /home/YOUR_USERNAME/ros2_ws/install/setup.bash && ros2 launch ros_web_controller web_control.launch.py'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Replace YOUR_USERNAME
sudo sed -i "s/YOUR_USERNAME/$USER/g" /etc/systemd/system/ros_web_controller.service

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable ros_web_controller
sudo systemctl start ros_web_controller

# Check status
sudo systemctl status ros_web_controller
```

---

## Usage

### Launch

```bash
# Load ROS2 environment
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash

# Start web controller
ros2 launch ros_web_controller web_control.launch.py
```

### Access

1. Check robot IP: `hostname -I`
2. Open browser: `http://ROBOT_IP:8080`
3. (iPhone) Safari → Share → "Add to Home Screen" for app-like experience

### Launch Parameters

```bash
ros2 launch ros_web_controller web_control.launch.py \
    web_port:=8080 \
    rosbridge_port:=9090
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `web_port` | 8080 | HTTP web server port |
| `rosbridge_port` | 9090 | WebSocket port |

---

## ROS2 Topics

### Published (Web → Robot)

| Topic | Type | Description |
|-------|------|-------------|
| `/cmd_vel` | geometry_msgs/Twist | Velocity command |

### Subscribed (Robot → Web)

| Topic | Type | Description |
|-------|------|-------------|
| `/scan` | sensor_msgs/LaserScan | LiDAR scan data |
| `/camera/image/compressed` | sensor_msgs/CompressedImage | Compressed camera image |

> **Note**: Topic names can be changed in the web UI. Match them to your robot's configuration.

---

## Camera Streaming Options

### rosbridge Mode (Default)
- Uses rosbridge WebSocket for image transport
- Images are Base64 encoded (~33% overhead)
- Works out of the box, no additional setup
- **Recommended for low resolution (320x240, 640x480)**

### MJPEG Mode (Lower Latency)
- Requires `web_video_server` package
- Direct HTTP streaming, no encoding overhead
- Recommended for high resolution or real-time control

```bash
# Install web_video_server
sudo apt install ros-humble-web-video-server

# Add to launch or run separately
ros2 run web_video_server web_video_server
```

### Jetson Camera Examples

```bash
# USB Camera
ros2 run usb_cam usb_cam_node_exe --ros-args \
    -p video_device:=/dev/video0 \
    -p image_width:=640 \
    -p image_height:=480 \
    -p framerate:=15.0

# CSI Camera (NVIDIA)
ros2 run v4l2_camera v4l2_camera_node --ros-args \
    -p video_device:=/dev/video0 \
    -p image_size:=[640,480]

# Check available cameras
v4l2-ctl --list-devices
ls /dev/video*
```

### Compress Raw Images

If your camera only publishes raw images:

```bash
ros2 run image_transport republish raw compressed \
    --ros-args \
    -r in:=/camera/image_raw \
    -r out/compressed:=/camera/image_raw/compressed
```

---

## Package Structure

```
ros-websocket/
├── package.xml                 # ROS2 package metadata
├── setup.py                    # Python package config
├── setup.cfg
├── README.md
│
├── launch/
│   └── web_control.launch.py   # Main launch file
│
├── ros_web_controller/         # Python module
│   ├── __init__.py
│   └── web_server.py           # HTTP server node
│
├── web/
│   └── index.html              # Web UI (robot)
│
├── docs/
│   └── index.html              # GitHub Pages demo
│
└── resource/
    └── ros_web_controller      # ament resource marker
```

---

## Controls

### Keyboard

| Key | Action |
|-----|--------|
| W / ↑ | Forward |
| S / ↓ | Backward |
| A / ← | Turn Left |
| D / → | Turn Right |
| Space | Stop |

### Touch/Mouse
- Joystick: Drag anywhere in the joystick area
- D-Pad: Tap and hold direction buttons

---

## Troubleshooting

### Jetson Specific Issues

#### ROS2 not found after reboot

```bash
# Check if sourced in bashrc
cat ~/.bashrc | grep ros

# If missing, add:
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

#### Build fails with memory error

```bash
# Jetson has limited RAM, use single thread
colcon build --packages-select ros_web_controller --executor sequential

# Or add swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### Permission denied on camera

```bash
# Add user to video group
sudo usermod -aG video $USER

# Reboot or re-login
```

#### Network port already in use

```bash
# Check what's using ports
sudo ss -tlnp | grep -E '8080|9090'

# Kill process if needed
sudo kill -9 <PID>
```

### General Issues

#### Web page not loading

```bash
# Check if nodes are running
ros2 node list
# Should show: /web_server, /rosbridge_websocket

# Check ports
ss -tlnp | grep -E '8080|9090'

# Open firewall
sudo ufw allow 8080
sudo ufw allow 9090
```

#### rosbridge connection failed

```bash
# Check ROS2 is working
ros2 topic list

# Check browser console (F12) for WebSocket errors
# Common issue: wrong IP or port blocked
```

#### Camera not showing

```bash
# List image topics
ros2 topic list | grep -i image

# Verify camera is publishing
ros2 topic hz /camera/image_raw

# If only raw images, see "Compress Raw Images" section above
```

#### LiDAR not showing

```bash
# Find scan topics
ros2 topic list | grep scan

# Verify data
ros2 topic echo /scan --once

# Check message type
ros2 topic info /scan
# Should be: sensor_msgs/msg/LaserScan
```

#### cmd_vel not working

```bash
# Check if topic is being published
ros2 topic echo /cmd_vel

# Manual test
ros2 topic pub /cmd_vel geometry_msgs/Twist \
    "{linear: {x: 0.1}, angular: {z: 0.0}}"

# Check subscriber
ros2 topic info /cmd_vel
```

#### High latency on camera

1. Lower resolution (320x240 or 640x480)
2. Lower framerate (10-15 fps)
3. Use compressed topic instead of raw
4. Try MJPEG mode with web_video_server
5. Check WiFi signal strength

---

## Dependencies

- `rosbridge_server` - WebSocket ↔ ROS2 bridge
- `rclpy` - ROS2 Python client
- `sensor_msgs` - Image, LaserScan messages
- `geometry_msgs` - Twist message
- `cv_bridge` - OpenCV bridge (optional)
- `image_transport` - Image transport plugins (optional)

---

## Performance Tips

### For Low Latency

```bash
# Use compressed images at lower resolution
# In camera node:
-p image_width:=320
-p image_height:=240
-p framerate:=15.0

# Or use MJPEG mode in web UI
```

### For Bandwidth Limited Networks

- Use 320x240 resolution
- 10-15 fps is sufficient for control
- Base64 overhead is ~33%, acceptable at low res
- MJPEG is more efficient at higher resolutions

### JetBot Specific

```bash
# Typical JetBot topics
/jetbot/cmd_vel          # Motor control
/jetbot/camera/image     # Camera
/scan                    # LiDAR (if equipped)
```

---

## License

MIT
