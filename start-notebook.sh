#!/bin/bash

# If any command fails, exit with the code of the failing command
set -e

# Overwrite permission changes when mounting persistent volumes.
sudo chown ubuntu /home/ubuntu
# sudo chmod -R 755 /home/ubuntu
sudo fix-permissions /home/ubuntu

# Assumes that a .netrc has been created in the volume
# TODO: upload an encrypted file, decrypt before the build,
# and copy to Dockerfile. Probably need to make the registry
# private as well
ln -s $HOME/notebooks/.netrc $HOME/.netrc

mkdir -p /home/ubuntu/notebooks

exec jupyter notebook $*
