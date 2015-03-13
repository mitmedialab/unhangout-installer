#!/bin/bash

# Removes all files associated with the development environment, use with
# extreme caution!

VM_INSTALL_DIR="${HOME}/vagrant/unhangout"

find_full_path_to_file() {
  local CWD=`pwd`
  local DIR=`dirname $0`
  local FULL_PATH=`echo "$(cd "$DIR"; pwd)"`
  cd $CWD
  echo "$FULL_PATH"
}

VAGRANT_CONFIG_DIR=`find_full_path_to_file`

if [ -f ${VAGRANT_CONFIG_DIR}/settings.sh ]; then
  . ${VAGRANT_CONFIG_DIR}/settings.sh
fi

CWD=`pwd`

if [ -d $VM_INSTALL_DIR ]; then
  echo -n "Are you sure you want to remove all of ${VM_INSTALL_DIR}? (y/N): "
  read KILL_VM

  if [ "$KILL_VM" = "y" ]; then
    echo "Removing $VM_INSTALL_DIR development virtual machine"
    cd $VM_INSTALL_DIR
    vagrant halt
    vagrant destroy -f
    cd $CWD
    rm -rf $VM_INSTALL_DIR

    echo "Removal complete. DNS entries added to /etc/hosts will need
  to be removed manually."
  else
    echo "User cancelled"
  fi
else
  echo "$VM_INSTALL_DIR does not exist, skipping."
fi
