#! /bin/bash
#
# Trigger a full reload of all sysctl variables.
#
# This is necessary because only a full restart of the network init script
# calls the helper that does this reload. That's a bit of overkill when all
# we want is to make sure the any packages that add something to /etc/sysctl.d
# will have their values available immediately.

# Source function library.
. /etc/init.d/functions

apply_sysctl

