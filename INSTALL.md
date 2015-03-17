# Overview

Installation is fairly straightforward:

 * Copy and edit some simple configuration files.
 * Load the Salt configuration to the server.
 * Run the installation.

## Initial configuration

 * In the <code>salt/pillar/server</code> directory, you'll find three example configuration files: one for development, one for production, and one for common settings across environments.
 * Copy the relevant example files in the same directory, removing the .example extension (eg. <code>development.sls.example</code> becomes <code>development.sls</code>).
 * Edit the configurations to taste. You can reference salt/salt/vars.jinja to see what variables are available, and the defaults for each.
 * If you wish to use custom SSL .crt and .key files, drop them into the <code>salt/salt/service/unhangout/ssl</code> directory, with a name matching the value of the <code>unhangout_domain</code> variable (in the form of <code>[unhangout_domain].crt</code> and <code>[unhangout_domain].key</code>). If no custom files are provided, dummy .crt and .key files will be used.
 * It's highly recommended to provide SSH public keys for those users you wish to have root access to the server. See the example configurations.
 * It's also possible to provide some other customizations for the Nginx portion of the install, but it's not necessary. See salt/salt/vars.jinja for more details.

## Development setup with Vagrant

 * Install the latest versions of [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org). OS X [Homebrew](http://brew.sh) users, consider easy installation via [Homebrew Cask](http://caskroom.io).
 * From the command line, change to the <code>vagrant</code> directory, and you'll find <code>settings.sh.example</code>. Copy that file in the same directory to <code>settings.sh</code>.
 * Edit to taste, the default values will most likely work just fine.
 * From the command line, run <code>./development-environment-init.sh</code>.
 * Once the script successfully completes the pre-flight checks, it will automatically handle the rest of the installation and setup. Relax, grab a cup of chai, and watch the setup process roll by on screen. :)
 * After script completion, run <code>./manage-vm.sh start</code>.
 * Visit <code>https://localhost:7778</code> in your browser, and you should see the main page for the Unhangout software.
 * The setup script outputs optional configuration you can add to your .ssh/config file, to enable easy root SSH access to the server if you configured an SSH pubkey as above.
 * The installed virtual machine can be controlled like any other Vagrant VM. See [this Vagrant cheat sheet](http://notes.jerzygangi.com/vagrant-cheat-sheet) for more details. 
 * If for any reason the installation fails, or you just want to completely remove the installed virtual machine, run the <code>vagrant/kill-development-environment.sh</code> script from the command line.

## Production setup

 * Set up a publicly accessible server (currently only [RHEL](http://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)/[CentOS](http://www.centos.org) 5.x/6.x and similar variants).
 * Make sure the server has access to the internet, including DNS resolution, and a valid, fully qualified host name configured.
 * Load the appropriate bootstrap script from the <code>server-bootstrap</code> directory (currently only <code>el.sh</code>) to the server, and make it executable.
 * Execute the bootstrap script. When prompted for the server environment, be sure to enter <code>production</code>.
 * Once the script completes successfully, follow the post-bootstrap instructions, with the following knowledge:
   * 'salt configuration' refers to the <code>salt/salt</code> directory of this software
   * 'pillar configuration' refers the <code>salt/pillar</code> directory of this software.

## Working on the installed code.

 * On all environments, the Unhangout code base is installed at <code>/usr/local/node/unhangout</code>, and start/stop/restart of the server can be managed by the script installed at <code>/etc/init.d/unhangout</code>.
 * On production environments, all essential services are monitored via monit, and start/stop/restart of the services should be handled via [monit commands](http://mmonit.com/monit/documentation/monit.html#Arguments).
 * On Vagrant installations, the unhangout codebase can also be accessed directly from the host machine, in the <code>unhangout</code> directory inside the <code>VM_INSTALL_DIR</code> directory specified in <code>settings.sh</code>. This enables use of your favorite editor instead of the more limited options on the virtual machine.
 * The unhangout code base is a git clone, and git is installed and ready to use with it.

## Known issues

 * Vagrant installations using <code>vagrant/development-environment-init.sh</code> have a glitch where the Unhangout service doesn't have access to the files on the host machine until after boot. Each time the VM is rebooted, you must log into the server and run <code>service unhangout start</code> to activate the Unhangout node service. Or, you can use the <code>vagrant/manage-vm.sh</code> script to start the server, which will handle that for you.
 * Production installations fail to start the Unhangout service and its Monit monitoring after the initial Salt deployment. Running <code>service unhangout start</code>, followed by <code>monit start unhangout</code> fixes the issue. Subsequent server reboots do not have this issue.
