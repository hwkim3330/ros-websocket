# ROS WebSocket Robot Controller

웹 브라우저에서 ROS2 로봇(Jetson Orin Nano JetBot)을 제어하는 패키지입니다.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Device                            │
│              (iPhone / Android / Laptop / PC)                   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Web Browser (Safari/Chrome)                 │   │
│  │  ┌─────────────────────────────────────────────────────┐│   │
│  │  │              index.html (PWA)                       ││   │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             ││   │
│  │  │  │ Control │  │ Camera  │  │  LiDAR  │             ││   │
│  │  │  │Joystick │  │  View   │  │  View   │             ││   │
│  │  │  └─────────┘  └─────────┘  └─────────┘             ││   │
│  │  └─────────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │  WiFi Connection
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                 Jetson Orin Nano (JetBot)                       │
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐│
│  │   HTTP Server       │    │        rosbridge_server         ││
│  │   (Port 8080)       │    │        (Port 9090)              ││
│  │                     │    │                                 ││
│  │  Serves index.html  │    │  WebSocket ↔ ROS2 Bridge        ││
│  │  web_server.py      │    │                                 ││
│  └─────────────────────┘    └───────────────┬─────────────────┘│
│                                             │                   │
│  ┌──────────────────────────────────────────▼─────────────────┐│
│  │                      ROS2 (Humble)                         ││
│  │  ┌────────────┐  ┌─────────────┐  ┌──────────────────────┐││
│  │  │  /cmd_vel  │  │   /scan     │  │ /camera/image/       │││
│  │  │  (Twist)   │  │ (LaserScan) │  │    compressed        │││
│  │  └─────┬──────┘  └──────┬──────┘  └───────────┬──────────┘││
│  └────────┼────────────────┼─────────────────────┼───────────┘│
│           │                │                     │             │
│  ┌────────▼────────┐ ┌─────▼─────┐  ┌────────────▼───────────┐│
│  │  Motor Driver   │ │   LiDAR   │  │        Camera          ││
│  │  (Wheel Control)│ │  Sensor   │  │       (CSI/USB)        ││
│  └─────────────────┘ └───────────┘  └────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
[Joystick Touch] → [JavaScript] → [WebSocket] → [rosbridge] → [/cmd_vel] → [Motors]
                                                     ↑
[Camera Feed]   ← [img.src]    ← [WebSocket] ← [rosbridge] ← [/camera/image]
[LiDAR View]    ← [Canvas]     ← [WebSocket] ← [rosbridge] ← [/scan]
```

## Demo

GitHub Pages: https://hwkim3330.github.io/ros-websocket

## Quick Start

### 1. Jetson에서 설치

```bash
# Clone
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

# Install rosbridge
sudo apt install ros-humble-rosbridge-server

# Build
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash
```

### 2. 실행

```bash
ros2 launch ros_web_controller web_control.launch.py
```

### 3. 접속

브라우저에서 `http://젯봇IP:8080` 접속

- iPhone: Safari에서 접속 → "홈 화면에 추가"로 앱처럼 사용
- Android: Chrome에서 접속 → 메뉴 → "홈 화면에 추가"
- PC/Laptop: 아무 브라우저에서 접속

## Package Structure

```
ros_web_controller/
├── package.xml                    # ROS2 패키지 정의
├── setup.py                       # Python 패키지 설정
├── launch/
│   ├── web_control.launch.py      # 메인 런치 (웹서버 + rosbridge)
│   └── rosbridge_websocket.launch.xml
├── ros_web_controller/
│   ├── __init__.py
│   └── web_server.py              # HTTP 서버 노드 (8080)
├── web/
│   └── index.html                 # 웹 UI (iOS 스타일)
├── scripts/
│   └── quick_start.sh
└── README.md
```

## Features

| Feature | Description |
|---------|-------------|
| Joystick | 터치/마우스 드래그로 로봇 조작 |
| D-Pad | 방향 버튼으로 간단 조작 |
| Keyboard | WASD / 화살표 키 지원 |
| Camera | Compressed/Raw 이미지 스트리밍 |
| LiDAR | LaserScan 실시간 시각화 |
| Speed Control | 최대 속도 슬라이더 조절 |
| Auto-connect | 같은 호스트 자동 연결 |
| PWA | 홈 화면 추가로 앱처럼 사용 |

## Controls

| Input | Action |
|-------|--------|
| W / ↑ | 전진 |
| S / ↓ | 후진 |
| A / ← | 좌회전 |
| D / → | 우회전 |
| Space | 정지 |
| Joystick | 자유 이동 |

## ROS Topics

### Published
- `/cmd_vel` (geometry_msgs/Twist) - 로봇 속도 명령

### Subscribed (선택)
- `/camera/image_raw/compressed` (sensor_msgs/CompressedImage)
- `/scan` (sensor_msgs/LaserScan)

## Ports

| Port | Service |
|------|---------|
| 8080 | HTTP 웹서버 (index.html) |
| 9090 | WebSocket (rosbridge) |

```bash
# 포트 변경
ros2 launch ros_web_controller web_control.launch.py web_port:=8888 rosbridge_port:=9999
```

## Troubleshooting

### 연결 안됨
```bash
# rosbridge 상태 확인
ros2 topic list

# 포트 확인
netstat -tlnp | grep -E '8080|9090'

# 방화벽 확인
sudo ufw status
sudo ufw allow 8080
sudo ufw allow 9090
```

### 카메라 안보임
```bash
# 토픽 확인
ros2 topic list | grep image

# Compressed 이미지로 변환 (필요시)
ros2 run image_transport republish raw compressed \
  --ros-args -r in:=/camera/image_raw \
  -r out/compressed:=/camera/image_raw/compressed
```

### LiDAR 안보임
```bash
# 토픽 확인
ros2 topic list | grep scan
ros2 topic echo /scan --once
```

## License

MIT
