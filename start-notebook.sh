#!/bin/bash

# If any command fails, exit with the code of the failing command
set -e

# Overwrite permission changes when mounting persistent volumes.
sudo chown ubuntu /home/ubuntu
sudo chgrp users /home/ubuntu

git config --global user.name "Panos Ipeirotis"
git config --global user.email "ipeirotis@gmail.com"

mkdir -p /home/ubuntu/notebooks

exec jupyter notebook $*
