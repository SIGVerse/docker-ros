# docker-ros

This repository provides an Ubuntu desktop Docker container (with VNC access) for SIGVerse.  
It uses the following image:  
https://github.com/Tiryoh/docker-ros2-desktop-vnc

## Build and publish the Docker image

**This procedure is for SIGVerse administrators. Users do not need to run it.**

**We do not provide a Dockerfile.** Setting up the environment as `ubuntu` during `docker build` was difficult.

1. Install Docker Desktop:  
   https://www.docker.com/products/docker-desktop/
1. Start Docker Desktop and make sure it is running.
1. Open Windows PowerShell.
1. Run the version command to confirm that the `docker` command works:  
   ```sh
   docker --version
   ```
1. Sign in to Inamura Lab's Docker Hub account with `docker login`. (ID=`inamuralab` / password: confirm separately)  
   ```sh
   docker login
   ```
1. Pull the base image, then create and start a container:  
   ```sh
   docker run -p 6080:80 --security-opt seccomp=unconfined --shm-size=512m ghcr.io/tiryoh/ros2-desktop-vnc:humble
   ```
1. Wait until the container is ready. If it looks like the following, startup is complete:  
   ![launch-base-image](images/launch-base-image.png "Launch Base Image")
1. In Docker Desktop, confirm that the container appears in **Containers**. The container name is generated randomly.  
   ![base-image-container](images/base-image-container.png "Base Image Container")
1. Open a web browser and go to:  
   http://127.0.0.1:6080/
1. Click the connect button.  
   The Ubuntu desktop will appear.   
   A VNC tool panel is available on the left side of the screen.
1. On the desktop, start Terminator.
1. Install SIGVerse:  
   ```sh
   wget https://raw.githubusercontent.com/SIGVerse/docker-ros/main/humble/sigverse_setup.sh
   chmod +x sigverse_setup.sh
   ./sigverse_setup.sh
   ```
1. Remove unnecessary files:  
   ```sh
   rm sigverse_setup.sh
   sudo rm -rf /var/lib/apt/lists/*
   ```
1. Download `sigverse_commands.txt`:  
   ```sh
   wget https://raw.githubusercontent.com/SIGVerse/docker-ros/refs/heads/main/humble/sigverse_commands.txt
   ```
1. Copy `sigverse_commands.txt` to the desktop.
1. Confirm that the ROS 2 node for HSR starts:  
   ```sh
   source ~/.bashrc
   ros2 launch sigverse_hsr_teleop_key teleop_key_launch.xml
   ```
1. Use the VNC tool panel on the left to disconnect the VNC session.
1. In Docker Desktop, stop the base image container.
1. Commit the container and publish the image to Docker Hub.  
   Run the following commands in Windows PowerShell.  
   Replace `<Container ID>` with the Container ID shown in Docker Desktop, and update the version number as needed.  
   ```sh
   docker commit <Container ID> sigverse-ros2-humble:1.0
   docker tag sigverse-ros2-humble:1.0 inamuralab/sigverse-ros2-humble:1.0
   docker login
   docker push inamuralab/sigverse-ros2-humble:1.0
   ```

## Start the Docker container (first time)

1. Install Docker Desktop (if it is not installed):  
   https://www.docker.com/products/docker-desktop/
1. Start Docker Desktop and make sure it is running.
1. Open Windows PowerShell. (Run the following commands in Windows PowerShell.)
1. Pull the image, then create and start a container.  
   You can change the resolution by adding a resolution option (e.g., `-e RESOLUTION=1920x1080`).  
   ```sh
   docker run -p 6080:80 -p 9090:9090 -p 50001:50001 inamuralab/sigverse-ros2-humble:1.0
   ```
1. Wait until the container is ready. If it looks like the following, startup is complete:  
   ![launch-image](images/launch-base-image.png "Launch Image")
1. In Docker Desktop, confirm that the image appears in **Images**.  
   ![docker-desktop-images](images/docker-desktop-images.png "Docker Desktop Images")
1. In Docker Desktop, confirm that the container appears in **Containers**. The container name is generated randomly.  
   ![docker-desktop-containers](images/docker-desktop-containers.png "Docker Desktop Containers")

## Start the Docker container (second time and later)

Since the container already exists, you can start it from the container list in Docker Desktop.  

## Use the Docker container

1. Open a web browser and go to:  
   http://127.0.0.1:6080/
1. Click the connect button.  
   The Ubuntu desktop will appear.  
   A VNC tool panel is available on the left side of the screen.  
   On the desktop, `sigverse_commands.txt` is available and contains command examples.  
   ![vnc-desktop](images/vnc-desktop.png "VNC Desktop")
1. In Unity, set the IP address for ROS to `127.0.0.1`.  
   ![unity-settings](images/unity-settings.png "Unity Settings")

## Stop the Docker container

1. Use the VNC tool panel on the left to disconnect the VNC session.
1. In Docker Desktop, stop the container.

## Notes

### Saving the Docker image to a file

On Windows, run the following commands in PowerShell to save and load a Docker image file.

Save to a file:  
```sh
docker save inamuralab/sigverse-ros2-humble:1.0 -o docker-image-sigverse-humble.tar
```

Load from a file:  
```sh
docker load -i docker-image-sigverse-humble.tar
docker run -p 6080:80 -p 9090:9090 -p 50001:50001 inamuralab/sigverse-ros2-humble:1.0
```
