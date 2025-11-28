# ros_web_controller

<img width="1912" height="970" alt="image" src="https://github.com/user-attachments/assets/cbff4677-40b7-46fa-80c3-b5d9526b223d" />

A web-based robot controller for ROS2. Control your robot from any browser with real-time camera streaming and LiDAR visualization.

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
| Platform | Jetson Orin Nano (or any ROS2 system) |
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

## Installation

### 1. Clone to ROS2 workspace

```bash
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git
```

### 2. Install dependencies

```bash
sudo apt update
sudo apt install -y ros-humble-rosbridge-server
```

### 3. Build

```bash
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash
```

### 4. (Optional) Add to bashrc

```bash
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```

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

## Camera Streaming Options

### rosbridge Mode (Default)
- Uses rosbridge WebSocket for image transport
- Images are Base64 encoded (~33% overhead)
- Works out of the box, no additional setup

### MJPEG Mode (Lower Latency)
- Requires `web_video_server` package
- Direct HTTP streaming, no encoding overhead
- Recommended for real-time control

```bash
# Install web_video_server
sudo apt install ros-humble-web-video-server

# Add to launch or run separately
ros2 run web_video_server web_video_server
```

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
│   └── index.html              # Web UI
│
└── resource/
    └── ros_web_controller      # ament resource marker
```

## Launch Parameters

```bash
ros2 launch ros_web_controller web_control.launch.py \
    web_port:=8080 \
    rosbridge_port:=9090
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `web_port` | 8080 | HTTP web server port |
| `rosbridge_port` | 9090 | WebSocket port |

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

## Troubleshooting

### Web page not loading

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

### rosbridge connection failed

```bash
# Check ROS2 is working
ros2 topic list

# Check browser console (F12) for WebSocket errors
```

### Camera not showing

```bash
# List image topics
ros2 topic list | grep -i image

# If only raw images available, convert to compressed:
ros2 run image_transport republish raw compressed \
    --ros-args \
    -r in:=/camera/image_raw \
    -r out/compressed:=/camera/image_raw/compressed
```

### LiDAR not showing

```bash
# Find scan topics
ros2 topic list | grep scan

# Verify data
ros2 topic echo /scan --once
```

### cmd_vel not working

```bash
# Check if topic is being published
ros2 topic echo /cmd_vel

# Manual test
ros2 topic pub /cmd_vel geometry_msgs/Twist \
    "{linear: {x: 0.1}, angular: {z: 0.0}}"
```

## Dependencies

- `rosbridge_server` - WebSocket ↔ ROS2 bridge
- `rclpy` - ROS2 Python client
- `sensor_msgs` - Image, LaserScan messages
- `geometry_msgs` - Twist message

## License

MIT
