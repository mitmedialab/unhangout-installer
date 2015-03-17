# Overview

This project attempts to ease the installation and configuration of the [Unhangout](https://unhangout.media.mit.edu) online un-conference style conferencing software. After running the installation, users should have a fully-functioning [Unhangout codebase](https://github.com/drewww/unhangout) up and running on their server.

## Features

 * Well documented and easy to configure.
 * Leveraging [Salt](http://saltstack.com/community), automatically installs and configures all necessary software.
 * Development and production configurations ensure consistency across environments, with the necessary customizations for each.
 * Dead-easy setup for local development environments using [Vagrant](https://www.vagrantup.com).
 * Sensible defaults that are easily overridden via config files.
 * Easily extend the automated deployment scripts for further server customization.

## Installation

See [INSTALL.md](INSTALL.md)

## Caveats

 * Tested on recent versions of [OS X](https://www.apple.com/osx)/[Vagrant](https://www.vagrantup.com)/[VirtualBox](https://www.virtualbox.org) and [CentOS](http://www.centos.org) 6.x
 * Salt installation should work on [RHEL](http://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)/[CentOS](http://www.centos.org) and similar variants, versions 5.x and 6.x
 * No support for installation on other platforms, but they could be added fairly easily, I think. Patches welcome. :)
 * No [Windows](http://windows.microsoft.com) support yet for the [Vagrant](https://www.vagrantup.com) installation scripts.

## Support

The issue tracker for this project is provided to file bug reports, feature requests, and project tasks -- support requests are not accepted via the issue tracker. For all support-related issues, including configuration, usage, and training, consider hiring a competent consultant.
