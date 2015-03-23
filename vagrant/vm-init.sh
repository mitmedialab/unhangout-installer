#!/bin/bash

# Handles all details of setting up the Unhangout virtual server using Salt.

VAGRANT_CONFIG_DIR=$1
VM_INSTALL_DIR=$2
UNHANGOUT_GIT_DIR=$3
DEV_USER=$4
DEV_SERVER=$5
SALT_DIR="`dirname $VAGRANT_CONFIG_DIR 2> /dev/null`/salt"
VM_NODE_PROJECT_DIR="/usr/local/node"

SCRIPT_NAME=`basename $0`

usage() {
echo "
This script initializes a fully functional Unhangout server on a
development machine.

Usage: $SCRIPT_NAME <vagrant_config_dir> <vm_install_dir> <unhangout_git_dir> [dev_user] [dev_server]

  vagrant_config_dir: The directory containing the Vagrantfile to use.
  vm_install_dir: The directory to install the VM in.
  unhangout_git_dir: Full path to the git clone of the unhangout repository.
  dev_user: The user name of the user on the main development server.
  dev_server: The SSH config name of the main development server.

dev_user and dev_server are optional, if provided they will be used to download
the Salt configuration. Otherwise, the Salt configuration will installed from
[vagrant_config_dir]/salt if it is found there.
"
}

if [ "$1" = "help" ]; then
  usage
  exit 1
fi

if [ $# -lt 2 ]; then
  usage
  exit 1
fi

if [ -f ${VAGRANT_CONFIG_DIR}/settings.sh ]; then
  . ${VAGRANT_CONFIG_DIR}/settings.sh
fi

echo "Creating ${VM_INSTALL_DIR}..."
mkdir -p ${VM_INSTALL_DIR}

echo "Setting up Vagrant configuration for server..."
cd $VM_INSTALL_DIR
cp ${VAGRANT_CONFIG_DIR}/Vagrantfile .
# This is the directory that will sync with the VM's unhangout codebase.
mkdir unhangout
# Cross-platform trick for sed inline editing.
sed -i.bak "s%###SALT_DIR###%${SALT_DIR}%g" Vagrantfile
rm Vagrantfile.bak
sed -i.bak "s%###UNHANGOUT_GIT_DIR###%${UNHANGOUT_GIT_DIR}%g" Vagrantfile
rm Vagrantfile.bak
if [ -n "$DEV_SERVER" ]; then
  echo "Downloading salt config for dev user ${DEV_USER} from ${DEV_SERVER}..."
  rsync -avz --progress $DEV_SERVER:/home/${DEV_USER}/salt .
elif [ -d ${VAGRANT_CONFIG_DIR}/salt ]; then
  echo "Copying salt config from ${VAGRANT_CONFIG_DIR}/salt..."
  rsync -avz --progress ${VAGRANT_CONFIG_DIR}/salt .
fi

echo "Temporarily uninstalling vagrant-vbguest plugin (if necessary)..."
vagrant plugin uninstall vagrant-vbguest

echo "Booting server..."
vagrant up --no-provision

# This is necessary so that the vagrant-vbguest plugin can be properly
# installed.
echo "Updating server kernel..."
vagrant ssh -- "sudo yum clean all"
vagrant ssh -- "sudo yum -y update kernel*"

vagrant plugin install vagrant-vbguest

# Reloading here allows the vagrant-vbguest plugin to handle its job before
# the rest of the install.
echo "Provisioning server..."
vagrant reload --provision

# There is sometimes a slight delay in syncing files from the VM to a shared
# host directory, allow time for it.
echo "Waiting for $VM_NODE_PROJECT_DIR to sync to host..."
sleep 60

# Final reboot takes care of resetting SELinux, making sure all services
# come up on boot, etc.
echo "Rebooting server..."
vagrant reload

