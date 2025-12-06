# ROS Web Controller

<p align="center">
  <img src="web/img/keti.png" alt="KETI" height="50">
</p>

<p align="center">
  <strong>Jetson Orin Nano용 웹 기반 로봇 컨트롤러</strong><br>
  브라우저에서 로봇 제어 + 카메라 스트리밍 + LiDAR 시각화
</p>

<p align="center">
  <a href="https://hwkim3330.github.io/ros-websocket/">Live Demo</a> •
  <a href="#1-jetson-orin-nano-설치">설치 가이드</a>
</p>

---

## 원라인 설치

```bash
curl -sL https://raw.githubusercontent.com/hwkim3330/ros-websocket/main/install.sh | bash
```

> ROS2 Humble이 설치되어 있어야 합니다.

---

## 수동 설치 (Jetson Orin Nano)

```bash
# 1. 의존성 설치
sudo apt update
sudo apt install -y ros-humble-rosbridge-server

# 2. 패키지 클론 및 빌드
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git
cd ~/ros2_ws
colcon build --packages-select ros_web_controller --symlink-install
source install/setup.bash

# 3. 실행
ros2 launch ros_web_controller web_control.launch.py
```

**브라우저 접속:** `http://JETSON_IP:8080`

---

## 1. Jetson Orin Nano 설치

### 1-1. ROS2 Humble 설치 (처음 한번만)

```bash
# ROS2 저장소 추가
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 설치
sudo apt update
sudo apt install -y ros-humble-ros-base python3-colcon-common-extensions

# bashrc에 추가
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 1-2. 패키지 설치

```bash
# 의존성
sudo apt install -y ros-humble-rosbridge-server

# 클론
mkdir -p ~/ros2_ws/src && cd ~/ros2_ws/src
git clone https://github.com/hwkim3330/ros-websocket.git

# 빌드
cd ~/ros2_ws
colcon build --packages-select ros_web_controller --symlink-install
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 1-3. 실행

```bash
ros2 launch ros_web_controller web_control.launch.py
```

브라우저에서 `http://JETSON_IP:8080` 접속

---

## 2. 카메라 설정 (CSI)

### CSI 카메라 (IMX219) - 기본
```bash
# v4l2_camera 설치
sudo apt install -y ros-humble-v4l2-camera ros-humble-image-transport-plugins

# 실행
ros2 run v4l2_camera v4l2_camera_node --ros-args \
  -p video_device:=/dev/video0 \
  -p image_size:=[640,480] \
  -p camera_frame_id:=camera
```

### USB 카메라 (대안)
```bash
sudo apt install -y ros-humble-usb-cam
ros2 run usb_cam usb_cam_node_exe --ros-args \
  -p video_device:=/dev/video0 \
  -p image_width:=640 -p image_height:=480 -p framerate:=15.0
```

### MJPEG 모드 (저지연)
```bash
sudo apt install -y ros-humble-web-video-server
ros2 run web_video_server web_video_server
# 웹 UI에서 MJPEG 모드 선택
```

---

## 2-1. AI 기능 (TensorFlow.js)

웹 UI에 AI 객체 감지 기능 내장:

| 기능 | 설명 |
|------|------|
| **Object Detection** | COCO-SSD 모델로 80가지 객체 실시간 감지 |
| **Tracking** | 사람 추적 모드 - 자동으로 사람 방향으로 회전 |

**사용법:**
1. 카메라 시작
2. "Object Detection" 또는 "Tracking" 버튼 클릭
3. 첫 실행 시 모델 로드 (수 초 소요)

**지원 객체:** person, car, truck, bicycle, dog, cat, chair, tv, laptop, cell phone 등 80종

---

## 3. 자동 시작 (systemd)

```bash
sudo tee /etc/systemd/system/ros_web.service << 'EOF'
[Unit]
Description=ROS Web Controller
After=network.target

[Service]
User=jetson
ExecStart=/bin/bash -c 'source /opt/ros/humble/setup.bash && source /home/jetson/ros2_ws/install/setup.bash && ros2 launch ros_web_controller web_control.launch.py'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ros_web.service
```

---

## 4. 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         Web Browser                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────────┐ │
│  │   Camera   │  │   LiDAR    │  │  Joystick / D-Pad / WASD   │ │
│  └─────┬──────┘  └─────┬──────┘  └──────────────┬─────────────┘ │
└────────┼───────────────┼────────────────────────┼───────────────┘
         │               │                        │
         └───────────────┴────────────────────────┘
                         │ WebSocket :9090
┌────────────────────────▼────────────────────────────────────────┐
│                    Jetson Orin Nano                             │
│  ┌──────────────────┐      ┌──────────────────────────────────┐ │
│  │ HTTP Server :8080│      │      rosbridge_websocket :9090   │ │
│  └──────────────────┘      └───────────────┬──────────────────┘ │
│  ┌─────────────────────────────────────────▼──────────────────┐ │
│  │                      ROS2 Humble                           │ │
│  │   /cmd_vel (Twist)          ───────▶  Motor Driver         │ │
│  │   /scan (LaserScan)         ◀───────  LiDAR Sensor         │ │
│  │   /camera/image/compressed  ◀───────  Camera               │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. ROS2 토픽

| 방향 | 토픽 | 타입 | 설명 |
|------|------|------|------|
| **Publish** | `/cmd_vel` | `geometry_msgs/Twist` | 속도 명령 |
| **Subscribe** | `/scan` | `sensor_msgs/LaserScan` | LiDAR 데이터 |
| **Subscribe** | `/camera/image/compressed` | `sensor_msgs/CompressedImage` | 카메라 |

---

## 6. 조작법

| 입력 | 동작 |
|------|------|
| **조이스틱** | 드래그하여 속도 제어 |
| **D-Pad** | 방향 버튼 |
| **키보드** | WASD / 화살표 |
| **스페이스** | 긴급 정지 |

---

## 7. 문제 해결

```bash
# 노드 확인
ros2 node list  # /web_server, /rosbridge_websocket 표시되어야 함

# 포트 확인
ss -tlnp | grep -E '8080|9090'

# 방화벽 열기
sudo ufw allow 8080 && sudo ufw allow 9090

# 카메라 권한
sudo usermod -aG video $USER && reboot

# 빌드 메모리 부족 시
colcon build --executor sequential
```

---

## 8. 오프라인 설치

인터넷 없는 환경용:

```bash
# 1. 인터넷 되는 PC에서 의존성 다운로드
./scripts/install_dependencies.sh

# 2. ~/ros_web_deps/ 폴더를 USB로 Jetson에 복사

# 3. Jetson에서 오프라인 설치
./scripts/install_offline.sh
```

---

## 9. 파일 구조

```
ros-websocket/
├── install.sh                       # 원라인 설치 스크립트
├── launch/web_control.launch.py     # 런치 파일
├── ros_web_controller/
│   └── web_server.py                # HTTP 서버
├── web/
│   ├── index.html                   # 웹 UI (AI 포함)
│   ├── lib/
│   │   ├── roslib.min.js            # roslibjs
│   │   ├── tf.min.js                # TensorFlow.js
│   │   └── coco-ssd.min.js          # 객체 감지 모델
│   └── img/keti.png                 # 로고
├── scripts/
│   ├── install_dependencies.sh      # 의존성 다운로드
│   └── install_offline.sh           # 오프라인 설치
└── docs/                            # GitHub Pages 데모
```

---

## 필수 패키지

| 패키지 | 용도 | 설치 |
|--------|------|------|
| `ros-humble-rosbridge-server` | WebSocket 통신 | `sudo apt install ros-humble-rosbridge-server` |
| `ros-humble-usb-cam` | USB 카메라 | `sudo apt install ros-humble-usb-cam` |
| `ros-humble-v4l2-camera` | CSI 카메라 | `sudo apt install ros-humble-v4l2-camera` |

---

## License

MIT License - KETI
