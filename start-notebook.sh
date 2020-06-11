#!/bin/bash

# If any command fails, exit with the code of the failing command
set -e

# Overwrite permission changes when mounting persistent volumes.
sudo chmod -R 777 /home/ubuntu
sudo chown ubuntu /home/ubuntu

mkdir -p /home/ubuntu/notebooks

exec jupyter notebook $*
