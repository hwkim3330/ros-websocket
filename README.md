# ROS WebSocket Robot Controller

웹 브라우저에서 ROS2 로봇을 제어하는 패키지입니다.

## Demo

GitHub Pages: https://hwkim3330.github.io/ros-websocket

## Quick Start (Jetson)

```bash
# 1. Clone
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

# 2. Install dependencies
sudo apt install ros-humble-rosbridge-server

# 3. Build
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash

# 4. Run
ros2 launch ros_web_controller web_control.launch.py
```

## Access

브라우저에서 `http://젯봇IP:8080` 접속

## Structure

```
ros_web_controller/
├── package.xml
├── setup.py
├── launch/
│   ├── web_control.launch.py      # Main launch (web + rosbridge)
│   └── rosbridge_websocket.launch.xml
├── ros_web_controller/
│   ├── __init__.py
│   └── web_server.py              # HTTP server node
├── web/
│   └── index.html                 # Web UI
└── scripts/
    └── quick_start.sh
```

## Features

- Joystick / Keyboard control
- Camera streaming
- LiDAR visualization
- Auto-connect to local rosbridge
- Mobile-friendly

## License

MIT
