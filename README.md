# ros_web_controller
<img width="1912" height="970" alt="image" src="https://github.com/user-attachments/assets/cbff4677-40b7-46fa-80c3-b5d9526b223d" />

웹 브라우저에서 ROS2 로봇을 제어하는 패키지

## Requirements

| Component | Version |
|-----------|---------|
| Platform | Jetson Orin Nano |
| ROS2 | **Humble Hawksbill** |
| Ubuntu | 22.04 LTS |
| Python | 3.10+ |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Client (Phone/PC)                           │
│                                                                 │
│    Safari / Chrome 브라우저                                      │
│    http://JETBOT_IP:8080                                        │
└───────────────────────────┬─────────────────────────────────────┘
                            │ WiFi
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Jetson Orin Nano                              │
│                                                                 │
│  ┌──────────────────┐      ┌──────────────────────────────────┐│
│  │ web_server.py    │      │     rosbridge_server             ││
│  │ (HTTP :8080)     │      │     (WebSocket :9090)            ││
│  │                  │      │                                  ││
│  │ index.html 제공   │      │  JSON ↔ ROS2 메시지 변환          ││
│  └──────────────────┘      └──────────────┬───────────────────┘│
│                                           │                     │
│  ┌────────────────────────────────────────▼───────────────────┐│
│  │                       ROS2 Humble                          ││
│  │                                                            ││
│  │   /cmd_vel ─────────────────▶ 모터 드라이버                  ││
│  │   (geometry_msgs/Twist)                                    ││
│  │                                                            ││
│  │   /scan ◀─────────────────── LiDAR 센서                    ││
│  │   (sensor_msgs/LaserScan)                                  ││
│  │                                                            ││
│  │   /camera/image/compressed ◀─ 카메라                        ││
│  │   (sensor_msgs/CompressedImage)                            ││
│  └────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Installation

### 1. ROS2 워크스페이스에 클론

```bash
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git
```

### 2. 의존성 설치

```bash
sudo apt update
sudo apt install -y ros-humble-rosbridge-server
```

### 3. 빌드

```bash
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash
```

### 4. (선택) bashrc에 추가

```bash
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```

## Usage

### 실행

```bash
# ROS2 환경 로드
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash

# 웹 컨트롤러 실행
ros2 launch ros_web_controller web_control.launch.py
```

### 접속

1. 젯봇 IP 확인: `hostname -I`
2. 브라우저에서 `http://젯봇IP:8080` 접속
3. (iPhone) Safari → 공유 → "홈 화면에 추가"로 앱처럼 사용

## ROS2 Topics

### Published (웹 → 로봇)

| Topic | Type | Description |
|-------|------|-------------|
| `/cmd_vel` | geometry_msgs/Twist | 로봇 속도 명령 |

### Subscribed (로봇 → 웹)

| Topic | Type | Description |
|-------|------|-------------|
| `/scan` | sensor_msgs/LaserScan | LiDAR 스캔 데이터 |
| `/camera/image/compressed` | sensor_msgs/CompressedImage | 압축 카메라 이미지 |

> **Note**: 토픽 이름은 웹 UI에서 변경 가능. 로봇에 맞게 입력하세요.

### JetBot 기본 토픽 예시

```bash
# 토픽 목록 확인
ros2 topic list

# 일반적인 JetBot 토픽
/cmd_vel                          # 모터 제어
/scan                             # RPLidar 등
/camera/image_raw                 # Raw 이미지
/camera/image_raw/compressed      # Compressed 이미지
```

## Package Structure

```
ros-websocket/                  # = ros_web_controller 패키지
├── package.xml                 # ROS2 패키지 메타데이터
├── setup.py                    # Python 패키지 설정
├── setup.cfg
├── README.md
│
├── launch/
│   └── web_control.launch.py   # 메인 런치파일
│
├── ros_web_controller/         # Python 모듈
│   ├── __init__.py
│   └── web_server.py           # HTTP 서버 노드
│
├── web/
│   └── index.html              # 웹 UI
│
└── resource/
    └── ros_web_controller      # ament 리소스 마커
```

## Launch Parameters

```bash
ros2 launch ros_web_controller web_control.launch.py \
    web_port:=8080 \
    rosbridge_port:=9090
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `web_port` | 8080 | HTTP 웹서버 포트 |
| `rosbridge_port` | 9090 | WebSocket 포트 |

## Web UI Features

| Feature | Description |
|---------|-------------|
| Joystick | 터치/마우스로 자유롭게 이동 |
| D-Pad | 방향 버튼 (전진/후진/좌/우) |
| Keyboard | WASD 또는 화살표 키 |
| Speed Slider | 최대 속도 조절 |
| Camera | 실시간 카메라 스트리밍 |
| LiDAR | LaserScan 2D 시각화 |
| Topics | 사용 가능한 토픽 목록 |

## Keyboard Controls

| Key | Action |
|-----|--------|
| W / ↑ | 전진 |
| S / ↓ | 후진 |
| A / ← | 좌회전 |
| D / → | 우회전 |
| Space | 정지 |

## Troubleshooting

### 웹페이지 접속 안됨

```bash
# 서버 실행 확인
ros2 node list
# /web_server, /rosbridge_websocket 있어야 함

# 포트 확인
ss -tlnp | grep -E '8080|9090'

# 방화벽 열기
sudo ufw allow 8080
sudo ufw allow 9090
```

### rosbridge 연결 실패

```bash
# rosbridge 상태 확인
ros2 topic list
# 토픽이 보이면 ROS2 정상

# WebSocket 테스트
# 브라우저 콘솔(F12)에서 에러 확인
```

### 카메라 안보임

```bash
# 카메라 토픽 확인
ros2 topic list | grep -i image

# Compressed 이미지로 변환 (raw만 있을 때)
ros2 run image_transport republish raw compressed \
    --ros-args \
    -r in:=/camera/image_raw \
    -r out/compressed:=/camera/image_raw/compressed
```

### LiDAR 안보임

```bash
# LiDAR 토픽 확인
ros2 topic list | grep scan

# 데이터 확인
ros2 topic echo /scan --once
```

### cmd_vel 동작 안함

```bash
# 토픽 발행 확인
ros2 topic echo /cmd_vel

# 수동 테스트
ros2 topic pub /cmd_vel geometry_msgs/Twist \
    "{linear: {x: 0.1}, angular: {z: 0.0}}"
```

## Dependencies

- `rosbridge_server` - WebSocket ↔ ROS2 브릿지
- `rclpy` - ROS2 Python 클라이언트
- `sensor_msgs` - 이미지, LaserScan 메시지
- `geometry_msgs` - Twist 메시지

## License

MIT
