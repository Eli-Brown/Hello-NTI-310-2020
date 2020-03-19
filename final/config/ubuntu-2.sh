#/bin/bash

apt-get install nfs-client git -y

git-clone https://github.com/Eli-Brown/Hello-NTI-310-2020.git

showmount -e 10.128.0.18# where $ipaddress is the ip of your nfs server
mkdir /mnt/test 
echo "10.128.0.18:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
mount -a


echo "*.info;mail.none;authpriv.none;cron.none   @10.128.0.10" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
#Important: this should be the internal not external IP of the server or the dns name of your server.
