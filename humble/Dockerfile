FROM tiryoh/ros2-desktop-vnc:humble

WORKDIR /home/ubuntu/

RUN /bin/bash -c '. /opt/ros/humble/setup.bash; rosdep update; mkdir -p ros2_ws/src; cd ros2_ws; colcon build --symlink-install'

COPY sigverse_setup.sh /tmp/ 
RUN chmod +x /tmp/sigverse_setup.sh

RUN /bin/bash -c '. /opt/ros/humble/setup.bash; /tmp/sigverse_setup.sh' && rm -rf sigverse_tmp/ && rm -rf /var/lib/apt/lists/*

COPY sigverse_commands.txt Desktop/
RUN chmod -x Desktop/sigverse_commands.txt
