
#!/bin/bash
# note, this is only part of the ldap CLIENT/server install script.  These are the relevent sed lines.



apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nslcd debconf-utils git nfs-client
unset DEBIAN_FRONTEND

apt-get install nfs-client nfs-common -y




showmount -e 10.128.0.2 # where $ipaddress is the ip of your nfs server
mkdir /mnt/test 
echo "10.128.0.2:/var/nfsshare/testing        /mnt/test       nfs     defaults 0 0" >> /etc/fstab
mount -a


sed -i 's/passwd:         compat systemd/passwd:         compat systemd ldap/g' /etc/nsswitch.conf
sed -i 's/group:          compat systemd/group:          compat systemd ldap/g' /etc/nsswitch.conf
sed -i 's/password        \[success=1 user_unknown=ignore default=die\]     pam_ldap.so use_authtok try_first_pass/password        \[success=1 user_unknown=ignore default=die\]     pam_ldap.so try_first_pass/g' /etc/pam.d/common-password
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/base dc=example,dc=net/base dc=nti310,cd=local/g' /etc/ldap.conf
sed -i 's,uri ldapi:///,uri ldap://ldap,g' /etc/ldap.conf
sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=ldapadm,dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's/#nss_base_passwd ou=People,dc=padl,dc=com?one/nss_base_passwd  ou=People,dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's/#nss_base_group ou=Group,dc=padl,dc=com\?one/nss_base_group          ou=Group,dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's/#nss_base_shadow  ou=People,dc=padl,dc=com\?one/nss_base_shadow ou=People,dc=nti310,dc=local/g' /etc/ldap.conf
(2 tabs) pw and shadow are single spaces not escaping the question mark
systemctl restart sshd
echo "P@ssw0rd1" > /etc/ldap.secret
chmod 0600 /etc/ldap.secret
systemctl restart libnss-ldap
apt-get -y install debconf-utils

echo "ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select      3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean     true
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string      ldap://ldap
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net" > /tmp/ldap_debconf

while read line; do echo "$line" | debconf-set-selections; done < /tmp/ldap_debconf




# MOD 2/6/10 sed -i 's/#nss_base_passwd  ou=People,dc=padl,dc=com\?one/#nss_base_passwd  ou=People,dc=nti310,dc=local/g' /etc/ldap.conf

sed -i "s/#nss_base_group.[ \t]*ou=Group,dc=padl,dc=com?one/nss_base_group          ou=Group,dc=nti310,dc=local/g" /etc/ldap.conf
sed -i 's/#nss_base_passwd.[ \t]*ou=People,dc=padl,dc=com?one/nss_base_passwd        ou=People,dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's/#nss_base_shadow.[ \t]*ou=People,dc=padl,dc=com?one/nss_base_shadow        ou=People,dc=nti310,dc=local/g' /etc/ldap.conf

