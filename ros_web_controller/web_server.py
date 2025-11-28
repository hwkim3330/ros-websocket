#!/usr/bin/env python3
"""
Simple HTTP server for serving web interface files.
Runs alongside rosbridge to provide the robot control UI.
"""

import rclpy
from rclpy.node import Node
import http.server
import socketserver
import threading
import os
from ament_index_python.packages import get_package_share_directory


class WebServerHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler that serves from the web directory."""

    def __init__(self, *args, web_dir=None, **kwargs):
        self.web_dir = web_dir
        super().__init__(*args, directory=web_dir, **kwargs)

    def log_message(self, format, *args):
        """Suppress default logging."""
        pass


class WebServerNode(Node):
    def __init__(self):
        super().__init__('web_server')

        # Parameters
        self.declare_parameter('port', 8080)
        self.declare_parameter('web_dir', '')

        self.port = self.get_parameter('port').value
        web_dir_param = self.get_parameter('web_dir').value

        # Find web directory
        if web_dir_param:
            self.web_dir = web_dir_param
        else:
            try:
                pkg_share = get_package_share_directory('ros_web_controller')
                self.web_dir = os.path.join(pkg_share, 'web')
            except Exception:
                # Fallback to local directory
                self.web_dir = os.path.join(os.path.dirname(__file__), '..', 'web')

        self.get_logger().info(f'Web directory: {self.web_dir}')
        self.get_logger().info(f'Starting web server on port {self.port}')

        # Start HTTP server in a separate thread
        self.server_thread = threading.Thread(target=self._run_server, daemon=True)
        self.server_thread.start()

        # Get local IP
        import socket
        hostname = socket.gethostname()
        try:
            local_ip = socket.gethostbyname(hostname)
        except:
            local_ip = '127.0.0.1'

        self.get_logger().info(f'=' * 50)
        self.get_logger().info(f'Web interface available at:')
        self.get_logger().info(f'  http://localhost:{self.port}')
        self.get_logger().info(f'  http://{local_ip}:{self.port}')
        self.get_logger().info(f'=' * 50)

    def _run_server(self):
        """Run the HTTP server."""
        handler = lambda *args, **kwargs: WebServerHandler(
            *args, web_dir=self.web_dir, **kwargs
        )

        with socketserver.TCPServer(("", self.port), handler) as httpd:
            httpd.serve_forever()


def main(args=None):
    rclpy.init(args=args)
    node = WebServerNode()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
