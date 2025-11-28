# ROS WebSocket Robot Controller

Jetson Orin Nano JetBot을 웹 브라우저로 제어하는 ROS2 패키지

## Demo

GitHub Pages: https://hwkim3330.github.io/ros-websocket

(데모는 로봇 IP 입력 필요)

## 설치

**[ros_web_controller/README.md](ros_web_controller/README.md)** 참고

```bash
cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git
cd ~/ros2_ws
colcon build --packages-select ros_web_controller
```

## 실행

```bash
ros2 launch ros_web_controller web_control.launch.py
```

브라우저에서 `http://젯봇IP:8080` 접속

## Requirements

- **Platform**: Jetson Orin Nano
- **ROS2**: Humble Hawksbill
- **Ubuntu**: 22.04

## License

MIT
