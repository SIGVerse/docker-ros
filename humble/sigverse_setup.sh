#!/bin/bash

# Error Handling
set -e -o pipefail

readonly WORK_DIR=sigverse_tmp
readonly ABS_BASE_PATH=`pwd`
readonly SCRIPT=${BASH_SOURCE[0]##*/}

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

#############################################
# Error Handling Methods
#############################################

function throw_err() {
  echo $1 1>&2
  return 1
}

err_buf=""
function err() {
  # Usage: trap 'err ${LINENO[0]} ${FUNCNAME[1]}' ERR
  status=$?
  lineno=$1
  func_name=${2:-main}
  err_str="ERROR: [`date +'%Y-%m-%d %H:%M:%S'`] ${SCRIPT}:${func_name}() returned non-zero exit status ${status} at line ${lineno}"
  echo ${err_str} 
  err_buf+=${err_str}
}

function finally() {
  cd ${ABS_BASE_PATH}
#  rm -rf ${WORK_DIR}/*

  echo -e "\\n`date +'%Y-%m-%d %H:%M:%S'` Finished."
}

trap 'err ${LINENO[0]} ${FUNCNAME[1]}' ERR
trap finally EXIT

echo -e "`date +'%Y-%m-%d %H:%M:%S'` Started.\\n"

#############################################
# Main
#############################################

# Please install ROS 2
if [ -z $ROS_DISTRO ]; then
  throw_err "Please install ROS 2"
fi

# Please create a ROS workspace.
if [ ! -d ~/ros2_ws ]; then
  throw_err "Please create ROS workspace(~/ros2_ws)"
fi

sudo apt -y update 2>&1

# Add devel/setup.bash to .bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc 2>&1

source ~/.bashrc 2>&1

# Install Additional Dependencies
sudo apt install -y libncurses-dev 2>&1
sudo apt install -y python3-pip 2>&1

# Install ROS2 Packages
sudo apt install -y ros-$ROS_DISTRO-rosbridge-suite 2>&1
sudo apt install -y ros-$ROS_DISTRO-slam-toolbox 2>&1
sudo apt install -y ros-$ROS_DISTRO-xacro 2>&1
sudo apt install -y ros-$ROS_DISTRO-octomap 2>&1
sudo apt install -y ros-$ROS_DISTRO-hardware-interface 2>&1
sudo apt install -y ros-$ROS_DISTRO-ros2-control ros-$ROS_DISTRO-ros2-controllers ros-$ROS_DISTRO-controller-manager 2>&1
sudo apt install -y ros-$ROS_DISTRO-moveit ros-$ROS_DISTRO-moveit-ros-perception ros-$ROS_DISTRO-moveit-ros-occupancy-map-monitor 2>&1

# Install Mongo C driver
cd ${ABS_BASE_PATH}/${WORK_DIR} 2>&1
wget https://github.com/mongodb/mongo-c-driver/releases/download/2.0.2/mongo-c-driver-2.0.2.tar.gz 2>&1
tar zxf mongo-c-driver-2.0.2.tar.gz 2>&1
cd mongo-c-driver-2.0.2/build 2>&1
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_UNINSTALL=ON 2>&1
cmake --build . 2>&1
sudo cmake --install . 2>&1

# Install Mongo C++ driver
cd ${ABS_BASE_PATH}/${WORK_DIR} 2>&1
wget https://github.com/mongodb/mongo-cxx-driver/releases/download/r4.1.1/mongo-cxx-driver-r4.1.1.tar.gz 2>&1
tar zxf mongo-cxx-driver-r4.1.1.tar.gz 2>&1
cd mongo-cxx-driver-r4.1.1/build 2>&1
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local 2>&1
cmake --build . 2>&1
sudo cmake --install . 2>&1
sudo ldconfig 2>&1

# Install gnome-terminal
sudo apt -y install gnome-terminal 2>&1

# Install sigverse_ros_bridge
cd ~/ros2_ws/src 2>&1
git clone https://github.com/SIGVerse/sigverse_ros_package.git 2>&1

# ROS2 Build - Core Packages
cd ~/ros2_ws 2>&1
colcon build --symlink-install --packages-skip sigverse_turtlebot3 2>&1
source ~/ros2_ws/install/setup.bash 2>&1

#############################################

# Reset Error Handling
set -e



