# ros_web_controller

<p align="center">
  <img width="1912" alt="ROS Web Controller" src="https://github.com/user-attachments/assets/cbff4677-40b7-46fa-80c3-b5d9526b223d" />
</p>

<p align="center">
  <strong>Web-based robot controller for ROS2</strong><br>
  Browser-based control with camera streaming and LiDAR visualization
</p>

<p align="center">
  <a href="https://hwkim3330.github.io/ros-websocket/">Live Demo</a> •
  <a href="#jetson-orin-nano-setup">Jetson Setup</a> •
  <a href="#usage">Usage</a>
</p>

---

## Jetson Orin Nano Setup

### 1. Install ROS2 Humble

```bash
# Add ROS2 repository
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install
sudo apt update
sudo apt install -y ros-humble-ros-base ros-humble-rosbridge-server python3-colcon-common-extensions

# Add to bashrc
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 2. Build Package

```bash
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

cd ~/ros2_ws
colcon build --packages-select ros_web_controller --symlink-install
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 3. Run

```bash
ros2 launch ros_web_controller web_control.launch.py
```

### 4. Access

Open browser: `http://JETSON_IP:8080`

---

## Quick Start (Any ROS2 System)

```bash
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git
sudo apt install -y ros-humble-rosbridge-server
cd ~/ros2_ws && colcon build --packages-select ros_web_controller
source install/setup.bash
ros2 launch ros_web_controller web_control.launch.py
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Web Browser                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────────┐ │
│  │   Camera   │  │   LiDAR    │  │  Joystick / D-Pad / WASD   │ │
│  │  Viewer    │  │  Viewer    │  │       Controls             │ │
│  └─────┬──────┘  └─────┬──────┘  └──────────────┬─────────────┘ │
└────────│───────────────│────────────────────────│───────────────┘
         │               │                        │
         │   ┌───────────┴────────────────────────┘
         │   │      WebSocket (rosbridge :9090)
         │   │
┌────────▼───▼────────────────────────────────────────────────────┐
│                    Jetson Orin Nano                             │
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────────────────────┐ │
│  │ HTTP Server :8080│      │      rosbridge_websocket         │ │
│  │   (Web UI)       │      │          :9090                   │ │
│  └──────────────────┘      └───────────────┬──────────────────┘ │
│                                            │                    │
│  ┌─────────────────────────────────────────▼──────────────────┐ │
│  │                      ROS2 Humble                           │ │
│  │                                                            │ │
│  │   /cmd_vel (Twist)          ───────▶  Motor Driver         │ │
│  │   /scan (LaserScan)         ◀───────  LiDAR Sensor         │ │
│  │   /camera/image/compressed  ◀───────  Camera (USB/CSI)     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## ROS2 Topics

| Direction | Topic | Type | Description |
|-----------|-------|------|-------------|
| **Publish** | `/cmd_vel` | `geometry_msgs/Twist` | Velocity command |
| **Subscribe** | `/scan` | `sensor_msgs/LaserScan` | LiDAR data |
| **Subscribe** | `/camera/image/compressed` | `sensor_msgs/CompressedImage` | Camera |

---

## Camera Setup

### USB Camera
```bash
sudo apt install -y ros-humble-usb-cam
ros2 run usb_cam usb_cam_node_exe --ros-args \
    -p video_device:=/dev/video0 \
    -p image_width:=640 -p image_height:=480 -p framerate:=15.0
```

### CSI Camera (IMX219)
```bash
sudo apt install -y ros-humble-v4l2-camera
ros2 run v4l2_camera v4l2_camera_node --ros-args -p video_device:=/dev/video0
```

### MJPEG Mode (Lower Latency)
```bash
sudo apt install -y ros-humble-web-video-server
ros2 run web_video_server web_video_server
# Select MJPEG mode in web UI
```

---

## Autostart (systemd)

```bash
sudo tee /etc/systemd/system/ros_web.service << EOF
[Unit]
Description=ROS Web Controller
After=network.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'source /opt/ros/humble/setup.bash && source ~/ros2_ws/install/setup.bash && ros2 launch ros_web_controller web_control.launch.py'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ros_web.service
```

---

## Controls

| Input | Action |
|-------|--------|
| **Joystick** | Drag to control velocity |
| **D-Pad** | Direction buttons |
| **Keyboard** | WASD / Arrow keys |
| **Space** | Emergency stop |

---

## Troubleshooting

```bash
# Check nodes
ros2 node list  # Should show: /web_server, /rosbridge_websocket

# Check ports
ss -tlnp | grep -E '8080|9090'

# Open firewall
sudo ufw allow 8080 && sudo ufw allow 9090

# Camera permission
sudo usermod -aG video $USER && reboot

# Memory issue during build
colcon build --executor sequential
```

---

## Package Structure

```
ros-websocket/
├── launch/web_control.launch.py    # Main launch file
├── ros_web_controller/web_server.py # HTTP server
├── web/index.html                   # Web UI
└── docs/index.html                  # GitHub Pages demo
```

---

## License

MIT
