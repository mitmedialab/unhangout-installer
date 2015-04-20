/etc/yum.repos.d/CentOS-Base.repo:
  file:
    - order: 3
    - managed
    - source: salt://etc/yum.repos.d/CentOS-Base.repo
    - user: root
    - group: root
    - mode: 644

/etc/yum.repos.d/CentOS-Debuginfo.repo:
  file.absent:
    - order: 3

/etc/yum.repos.d/CentOS-fasttrack.repo:
  file.absent:
    - order: 3

/etc/yum.repos.d/CentOS-Media.repo:
  file.absent:
    - order: 3

/etc/yum.repos.d/CentOS-Vault.repo:
  file.absent:
    - order: 3

