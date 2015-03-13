/etc/yum.repos.d/CentOS-Base.repo:
  file:
    - managed
    - source: salt://etc/yum.repos.d/CentOS-Base.repo
    - user: root
    - group: root
    - mode: 644

/etc/yum.repos.d/CentOS-Debuginfo.repo:
  file.absent:
    - name: /etc/yum.repos.d/CentOS-Debuginfo.repo

/etc/yum.repos.d/CentOS-Media.repo:
  file.absent:
    - name: /etc/yum.repos.d/CentOS-Media.repo

