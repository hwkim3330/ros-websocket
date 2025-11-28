#!/usr/bin/env python3
"""
Launch file for ROS Web Controller.
Starts both rosbridge WebSocket server and HTTP web server.
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.substitutions import LaunchConfiguration
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory
import os


def generate_launch_description():
    # Parameters
    web_port = LaunchConfiguration('web_port', default='8080')
    rosbridge_port = LaunchConfiguration('rosbridge_port', default='9090')

    # Rosbridge launch file
    rosbridge_share = get_package_share_directory('rosbridge_server')
    rosbridge_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(rosbridge_share, 'launch', 'rosbridge_websocket_launch.xml')
        ),
        launch_arguments={'port': rosbridge_port}.items()
    )

    # Web server node
    web_server_node = Node(
        package='ros_web_controller',
        executable='web_server',
        name='web_server',
        parameters=[{'port': web_port}],
        output='screen'
    )

    return LaunchDescription([
        DeclareLaunchArgument(
            'web_port',
            default_value='8080',
            description='HTTP web server port'
        ),
        DeclareLaunchArgument(
            'rosbridge_port',
            default_value='9090',
            description='Rosbridge WebSocket port'
        ),
        rosbridge_launch,
        web_server_node,
    ])
