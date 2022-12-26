FROM tiryoh/ros-desktop-vnc:noetic

WORKDIR /home/ubuntu/

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; rosdep update; mkdir -p catkin_ws/src; cd catkin_ws/; catkin_make'

COPY sigverse_setup.sh /tmp/ 
RUN chmod +x /tmp/sigverse_setup.sh

RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; /tmp/sigverse_setup.sh'

RUN rm -rf sigverse_tmp/ && rm -rf /var/lib/apt/lists/*
COPY lxterminal.desktop Desktop/
COPY sigverse_commands.txt Desktop/
