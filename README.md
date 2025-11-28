# ROS WebSocket Robot Controller

웹 브라우저에서 ROS 로봇을 제어하는 웹 인터페이스입니다.

## Features

- **조이스틱 컨트롤**: 터치/마우스로 로봇 조작
- **키보드 컨트롤**: WASD 또는 화살표 키
- **카메라 스트리밍**: compressed/raw 이미지 토픽 지원
- **LiDAR 시각화**: 실시간 LaserScan 렌더링
- **토픽 브라우저**: 사용 가능한 ROS 토픽 목록

## Requirements

### 로봇 (Jetson)

```bash
# ROS2 rosbridge 설치 (Humble/Jazzy)
sudo apt install ros-${ROS_DISTRO}-rosbridge-server

# rosbridge 실행
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
```

### 사용 방법

1. 로봇에서 rosbridge 서버 실행 (포트 9090)
2. 웹페이지 접속: https://hwkim3330.github.io/ros-websocket
3. 로봇 IP 입력 후 Connect 클릭
4. 조이스틱 또는 키보드로 로봇 조작

## Controls

| 입력 | 동작 |
|------|------|
| W / ↑ | 전진 |
| S / ↓ | 후진 |
| A / ← | 좌회전 |
| D / → | 우회전 |
| Space | 정지 |
| 조이스틱 | 자유 이동 |

## ROS Topics

### Published
- `/cmd_vel` (geometry_msgs/Twist) - 로봇 속도 명령

### Subscribed (선택)
- 카메라: `/camera/image_raw/compressed` 등
- LiDAR: `/scan`

## Demo

GitHub Pages에서 바로 사용: https://hwkim3330.github.io/ros-websocket

## License

MIT
