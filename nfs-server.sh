#!/bin/bash
#for NFS-SERVER setup



yum install -y git



## added thurs2/6/20
yum install -y nfs-utils
mkdir /var/nfsshare
mkdir /var/nfsshare/devstuff
mkdir /var/nfsshare/testing
mkdir /var/nfsshare/home_dirs
chmod -R 777 /var/nfsshare/
systemctl enable rcpbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
cd /var/nfsshare/

echo "/var/nfsshare/home_dirs *(rw,sync,no_all_squash)
/var/nfsshare/devstuff  *(rw,sync,no_all_squash)
/var/nfsshare/testing   *(rw,sync,no_all_squash)" >> /etc/exports

systemctl restart nfs-server
#install net tools to get ifconfig
yum -y install net-tools
yum -y install openldap-servers openldap-clients


echo "10.128.0.4:/var/nfsshare/testing   
     /mnt/test       nfs     defaults 0 0" >> /etc/fstab

systemctl enable slapd
systemctl start slapd

yum -y install httpd

systemctl enable httpd
systemctl start httpd



systemctl restart httpd




