# Overview

This project attempts to ease the configuration and installation of the [Unhangout](https://unhangout.media.mit.edu) online un-conference style conferencing software. After running the installation, users should have a fully-functioning [Unhangout codebase](https://github.com/drewww/unhangout) up and running on their server.

## Features

 * Well documented and easy to configure.
 * Leveraging [Salt](http://saltstack.com/community), automatically installs and configures all necessary software.
 * Development and production configurations ensure consistency across environments, with the necessary customizations for each.
 * Dead-easy setup for local development environments using [Vagrant](https://www.vagrantup.com).
 * Sensible defaults that are easily overridden via config files.
 * Easily extend the automated deployment scripts for further server customization.

## Installation

See INSTALL.md

## Caveats

 * Tested on recent versions of OS X/Vagrant/Virtualbox and CentOS 6.x
 * Salt installation should work on RHEL/CentOS and similar variants, versions 5.x and 6.x
 * No support for installation on other platforms, but they could be added fairly easily, I think. Patches welcome. :)
