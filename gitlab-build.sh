#!/bin/bash

sudo apt-get update; sudo apt-get install linux-modules-$(uname -r) -y
sudo apt-get install sshpass fuse -y ; sudo modprobe fuse 

wget https://raw.githubusercontent.com/Nitrux/nitrux-repository-util/master/build-vvave.sh

chmod +x build-vvave.sh

./build-vvave.sh


export SSHPASS=$DEPLOY_PASS

sshpass -e scp -q -o stricthostkeychecking=no *.AppImage $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH
#sshpass -e ssh $DEPLOY_USER@$DEPLOY_HOST 'bash /home/packager/repositories/nomad-desktop/repositories_util.sh'
