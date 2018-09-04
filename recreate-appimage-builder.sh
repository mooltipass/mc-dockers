#!/bin/sh
# This script is intedned to be used in development environment on developer's local machine.
# Run this script every time you change mc-appimage-builder/Dockerfile
# to re-create and run a container with the new Docker image.

set -x
set -e

docker stop mc-appimage-builder || true

docker rm   mc-appimage-builder || true

docker build -t mc-appimage-builder mc-appimage-builder

# --cap-add SYS_ADMIN --cap-add MKNOD --device /dev/fuse:mrw
docker run \
  -t --name mc-appimage-builder -d -v $HOME/moolticute:/home/ubuntu/moolticute \
  mc-appimage-builder

docker ps
