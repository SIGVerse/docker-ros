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

# Please install ROS Noetic Ninjemys
# Run the ROS Installation page up to section 1.6 to install ROS Noetic Ninjemys. 
#   http://wiki.ros.org/noetic/Installation/Ubuntu
if [ -z $ROS_DISTRO ]; then
  throw_err "Please install ROS"
fi

# Then follow chapter 3 of the ROS tutorial to create a ROS workspace.</div>
#   http://wiki.ros.org/ROS/Tutorials/InstallingandConfiguringROSEnvironment
if [ ! -d ~/catkin_ws ]; then
  throw_err "Please create ROS workspace(~/catkin_ws)"
fi

sudo apt -y update 2>&1

# Add devel/setup.bash to .bashrc
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc 2>&1
source ~/.bashrc 2>&1

# Install ROSBridge_suite
sudo apt -y install ros-noetic-rosbridge-server 2>&1

# Install Mongo C driver
cd ${ABS_BASE_PATH}/${WORK_DIR} 2>&1
wget https://github.com/mongodb/mongo-c-driver/releases/download/1.4.2/mongo-c-driver-1.4.2.tar.gz -O mongo-c-driver-1.4.2.tar.gz 2>&1
tar zxvf mongo-c-driver-1.4.2.tar.gz 2>&1
cd mongo-c-driver-1.4.2 2>&1
./configure 2>&1
make 2>&1
sudo make install 2>&1

# Install Mongo C++ driver
cd ${ABS_BASE_PATH}/${WORK_DIR} 2>&1
wget https://github.com/mongodb/mongo-cxx-driver/archive/r3.0.3.tar.gz -O r3.0.3.tar.gz 2>&1
tar zxvf r3.0.3.tar.gz 2>&1
cd mongo-cxx-driver-r3.0.3/build 2>&1
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DLIBMONGOC_DIR=/usr/local -DLIBBSON_DIR=/usr/local .. 2>&1
sudo make EP_mnmlstc_core 2>&1
make 2>&1
sudo make install 2>&1

# Install gnome-terminal
sudo apt -y install gnome-terminal 2>&1

# sigverse_ros_bridge settings
cd ~/catkin_ws/src 2>&1
rm -fr sigverse_ros_package 2>&1
git clone https://github.com/SIGVerse/sigverse_ros_package.git 2>&1
cd .. 2>&1
catkin_make 2>&1

# Install TurtleBot3 Packages
sudo apt -y install ros-noetic-rgbd-launch 2>&1
sudo apt -y install ros-noetic-gmapping 2>&1
sudo apt -y install ros-noetic-turtlebot3* 2>&1

# Install PR2 Package
sudo apt -y install ros-noetic-pr2* 2>&1
cd $ROS_ROOT/../prosilica_camera 2>&1
sudo mkdir -p plugins 2>&1
sudo cp nodelet_plugins.xml plugins/ 2>&1

#############################################

# Reset Error Handling
set -e



