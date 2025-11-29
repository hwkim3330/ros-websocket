from setuptools import setup, find_packages
import os
from glob import glob

package_name = 'ros_web_controller'

setup(
    name=package_name,
    version='1.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/launch', glob('launch/*.py')),
        ('share/' + package_name + '/launch', glob('launch/*.xml')),
        ('share/' + package_name + '/web', glob('web/*.html')),
        ('share/' + package_name + '/web/lib', glob('web/lib/*')),
        ('share/' + package_name + '/web/img', glob('web/img/*')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='KETI',
    maintainer_email='your@email.com',
    description='Web-based robot controller with camera and LiDAR visualization',
    license='MIT',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'web_server = ros_web_controller.web_server:main',
        ],
    },
)
