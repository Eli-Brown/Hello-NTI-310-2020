#/bin/bash

apt-get install nfs-client nfs-common -y
showmount -e 10.128.0.4 # where $ipaddress is the ip of your nfs server
mkdir /mnt/test 

echo "10.128.0.221:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
ount -a
