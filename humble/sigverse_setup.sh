#!/usr/bin/env bash

# Error Handling
set -Eeo pipefail

exec 2>&1

readonly WORK_DIR="$(mktemp -d -t sigverse_tmp.XXXXXX)"
readonly ABS_BASE_PATH=`pwd`
readonly SCRIPT=${BASH_SOURCE[0]##*/}

# ROS2 workspace
readonly ROS2_WS="${HOME}/ros2_ws"

cd "${WORK_DIR}"

#############################################
# Error Handling Methods
#############################################

function throw_err() {
  echo "$1" 1>&2
  return 1
}

err_buf=""
function err() {
  # Usage: trap 'err ${LINENO[0]} ${FUNCNAME[1]}' ERR
  status=$?
  lineno=$1
  func_name=${2:-main}
  err_str="ERROR: [`date +'%Y-%m-%d %H:%M:%S'`] ${SCRIPT}:${func_name}() returned non-zero exit status ${status} at line ${lineno}"
  echo "${err_str}"
  err_buf+="${err_str}"
}

function finally() {
  status=$?
  cd "${ABS_BASE_PATH}" || true

  # Cleanup only on success (keep on failure for debug)
  if [[ $status -eq 0 ]]; then
    rm -rf "${WORK_DIR}"
  else
    echo "Keep temp dir for debug: ${WORK_DIR}" >&2
  fi

  echo -e "\\n$(date +'%Y-%m-%d %H:%M:%S') Finished."
}

trap 'err ${LINENO[0]} ${FUNCNAME[1]}' ERR
trap finally EXIT

echo -e "`date +'%Y-%m-%d %H:%M:%S'` Started.\\n"

#############################################
# Main
#############################################

# Please install ROS 2
if [[ -z "${ROS_DISTRO:-}" ]]; then
  throw_err "Please install ROS 2"
fi

# Please create a ROS workspace.
if [ ! -d "${ROS2_WS}" ]; then
  throw_err "Please create ROS workspace(${ROS2_WS})"
fi

sudo apt -y update

# Add install/setup.bash to .bashrc
SOURCE_LINE="source ${ROS2_WS}/install/setup.bash"
grep -qxF "$SOURCE_LINE" ~/.bashrc || echo "$SOURCE_LINE" >> ~/.bashrc

source "/opt/ros/${ROS_DISTRO}/setup.bash"

# Install Additional Dependencies
sudo apt install -y libncurses-dev
sudo apt install -y python3-pip

# Install ROS2 Packages
sudo apt install -y ros-$ROS_DISTRO-rosbridge-suite
sudo apt install -y ros-$ROS_DISTRO-slam-toolbox
sudo apt install -y ros-$ROS_DISTRO-xacro
sudo apt install -y ros-$ROS_DISTRO-octomap
sudo apt install -y ros-$ROS_DISTRO-hardware-interface
sudo apt install -y ros-$ROS_DISTRO-ros2-control ros-$ROS_DISTRO-ros2-controllers ros-$ROS_DISTRO-controller-manager
sudo apt install -y ros-$ROS_DISTRO-moveit ros-$ROS_DISTRO-moveit-ros-perception ros-$ROS_DISTRO-moveit-ros-occupancy-map-monitor

# Install Mongo C driver
cd "${WORK_DIR}"
wget https://github.com/mongodb/mongo-c-driver/releases/download/2.0.2/mongo-c-driver-2.0.2.tar.gz
tar zxf mongo-c-driver-2.0.2.tar.gz
cd mongo-c-driver-2.0.2/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_UNINSTALL=ON
cmake --build .
sudo cmake --install .

# Install Mongo C++ driver
cd "${WORK_DIR}"
wget https://github.com/mongodb/mongo-cxx-driver/releases/download/r4.1.1/mongo-cxx-driver-r4.1.1.tar.gz
tar zxf mongo-cxx-driver-r4.1.1.tar.gz
cd mongo-cxx-driver-r4.1.1/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local
cmake --build .
sudo cmake --install .
sudo ldconfig

# Install gnome-terminal
sudo apt -y install gnome-terminal

# Install sigverse_ros_bridge
cd "${ROS2_WS}/src"
git clone https://github.com/SIGVerse/sigverse_ros_package.git

# ROS2 Build - Core Packages
cd "${ROS2_WS}"
colcon build --symlink-install --packages-skip sigverse_turtlebot3
source "${ROS2_WS}/install/setup.bash"

#############################################


