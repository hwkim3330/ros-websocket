# ROS Web Controller

웹 브라우저에서 ROS2 로봇을 제어하는 패키지입니다.

## Features

- Joystick 컨트롤 (터치/마우스)
- 키보드 컨트롤 (WASD/화살표)
- 카메라 스트리밍 (compressed/raw)
- LiDAR 시각화 (LaserScan)
- 토픽 브라우저
- 자동 연결 (같은 호스트)

## Installation

```bash
# 1. 의존성 설치
sudo apt install ros-${ROS_DISTRO}-rosbridge-server

# 2. 워크스페이스에 패키지 복사
cd ~/ros2_ws/src
cp -r /path/to/ros_web_controller .

# 3. 빌드
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
source install/setup.bash
```

## Usage

### 방법 1: Launch 파일 (권장)

```bash
# rosbridge + web server 동시 실행
ros2 launch ros_web_controller web_control.launch.py
```

### 방법 2: 개별 실행

```bash
# Terminal 1: rosbridge
ros2 launch rosbridge_server rosbridge_websocket_launch.xml

# Terminal 2: web server
ros2 run ros_web_controller web_server
```

### 접속

브라우저에서:
- `http://로봇IP:8080`

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| web_port | 8080 | HTTP 서버 포트 |
| rosbridge_port | 9090 | WebSocket 포트 |

```bash
# 포트 변경
ros2 launch ros_web_controller web_control.launch.py web_port:=8888 rosbridge_port:=9999
```

## ROS Topics

### Published
- `/cmd_vel` (geometry_msgs/Twist)

### Subscribed (선택)
- 카메라: `/camera/image_raw/compressed` 등
- LiDAR: `/scan`

## Controls

| 입력 | 동작 |
|------|------|
| W / ↑ | 전진 |
| S / ↓ | 후진 |
| A / ← | 좌회전 |
| D / → | 우회전 |
| Space | 정지 |
| 조이스틱 | 자유 이동 |

## Troubleshooting

### 연결 안됨
```bash
# rosbridge 실행 확인
ros2 topic list
# /rosout 등이 보여야 함

# 포트 확인
netstat -tlnp | grep 9090
```

### 카메라 안보임
```bash
# 토픽 확인
ros2 topic list | grep image

# compressed 이미지 필요
ros2 run image_transport republish raw compressed --ros-args -r in:=/camera/image_raw -r out/compressed:=/camera/image_raw/compressed
```

## License

MIT
