#!/bin/sh

# Install Docker
sudo apt-get update && \
sudo apt-get install -y apt-transport-https ca-certificates && \
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list && \
sudo apt-get update && \
apt-cache policy docker-engine && \
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual && \
sudo apt-get update && \
sudo apt-get install -y docker-engine && \
sudo apt-get install -y gcc make && \
sudo apt-get install -y dkms linux-headers-generic && \
sudo usermod -aG docker $USER && \

# Blacklist nouveau driver
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf && \
echo "blacklist lbm-nouveau" >> /etc/modprobe.d/blacklist-nouveau.conf && \
echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf && \
echo "alias nouveau off" >> /etc/modprobe.d/blacklist-nouveau.conf && \
echo "alias lbm-nouveau off" >> /etc/modprobe.d/blacklist-nouveau.conf && \
echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf && \
sudo update-initramfs -u && \

# Download and install Nvidia driver
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/364.19/NVIDIA-Linux-x86_64-364.19.run && \
chmod +x NVIDIA-* && \
sudo sh ./NVIDIA-Linux-x86_64-364.19.run --dkms --silent && \

wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc.3/nvidia-docker_1.0.0.rc.3-1_amd64.deb && \
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb && \

# Download custom Dockerfile and build image
wget https://raw.githubusercontent.com/gmpetrov/y-dl-docker/master/Dockerfile.gpu && \
sudo docker build -t ysance/y-dl-docker:gpu -f Dockerfile.gpu . && \


# Run image
nvidia-docker run -it -p 8888:8888 -p 6006:6006 -v /sharedfolder:/root/sharedfolder ysance/y-dl-docker:gpu bash
