#!/bin/bash
# put this at the beginning of each of your scripts
# it will remove the centos7 repos, which are flakey right now
# and put in our (more stable) repositories.

for file in $( ls /etc/yum.repos.d/ ); do mv /etc/yum.repos.d/$file /etc/yum.repos.d/$file.bak; done


echo "[nti-310-epel]
name=NTI310 EPEL
baseurl=http://34.71.91.10/epel
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-base]
name=NTI310 BASE
baseurl=http://34.71.91.10/base
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-extras]
name=NTI310 EXTRAS
baseurl=http://34.71.91.10/extras/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo

echo "[nti-310-updates]
name=NTI310 UPDATES
baseurl=http://34.71.91.10/updates/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo
## create ryslog-server 1st via Gshell ##
yum install git 
git clone https://github.com/Eli-Brown/Hello-NTI-310-2020.git

echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.10" >> /etc/rsyslog.conf && systemctl restart rsyslog.service

#Important: this should be the internal not external IP of the server or the dns name of your server.
