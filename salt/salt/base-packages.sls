update-packages:
  pkg.uptodate

base-packages:
  pkg.installed:
    - pkgs:
      - bash-completion
      - colordiff
      - file
      - git
      - htop
      - lynx
      - man
      - man-pages
      - man-pages-overrides
      - mutt
      - ntp
      - openssh-clients
      - openssh-server
      - patch
      - patchutils
      - postfix
      - sed
      - system-config-firewall-tui
      - tcpdump
      - telnet
      - tmux
      - traceroute
      - unzip
      - vim-enhanced
      - yum-plugin-changelog
      - yum-utils

