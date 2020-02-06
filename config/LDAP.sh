#!/bin/bash
# ip address /phpldapadmin/cmd.php
## user : pgdbuser
## Password : pgdbpass
yum install -y git
cd /tmp
git clone https://github.com/nic-instruction/hello-nti-310.git

yum install -y openldap-servers openldap-clients git

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl enable slapd
systemctl start slapd

yum install -y httpd phpldapadmin

#Let's SELinux know what is going on
setsebool -P httpd_can_connect_ldap on

systemctl enable httpd
systemctl start httpd

sed -i 's,Require local,#Require local/n   Require all granted,g' /etc/httpd/conf.d/phpldapadmin.conf

unalias cp
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.orig		# make a copy of the origonal config file, we need the blowfish key
grep 'config.*blowfish' /etc/phpldapadmin/config.php.orig				# grep for the blowfish key so we can see it in the logs
rightkey=$( grep 'config.*blowfish' /etc/phpldapadmin/config.php.orig )	# use some rejex to get just the key and shove it into the variable 'right key'
cp /tmp/Hello-NTI-310/config/config.php /etc/phpldapadmin/config.php	# copy our pre-made config to config.php
			# changed Blowfish key 1/23/20
#sed -i "s/\$config->custom->session['blowfish'] = '62e55b69035c7d77960370a6c9e9d3ac';  # Autogenerated for ldap-c/$rightkey/g" /etc/phpldapadmin/config.php # fix the key
sed -i "s/\$config->custom->session\['blowfish'\] = '6ad4614a51893aaf046e2057e7870ae4'\;  # Autogenerated for ldap-c/$rightkey/g" /etc/phpldapadmin/config.php # fix the key

chown ldap:apache /etc/phpldapadmin/config.php

systemctl restart httpd

echo "phpldapadmin is now up and running"
echo "we are configuring ldap and ldapadmin"

#Generates and stores new passwd securely
newsecret=$(slappasswd -g)
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass
chmod 0600 /root/ldap_admin_pass   							#lock down PW

echo -e "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=nti310,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=nti310,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" > db.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif

#Auth restriction

echo 'dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,dc=nti310,dc=local" read by * none' >monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif

#Generates Certs

openssl req -new -x509 -nodes -out /etc/openldap/certs/nti310ldapcert.pem -keyout /etc/openldap/certs/nti310ldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=SCC/OU=IT/CN=nti310.local"

chown -R ldap. /etc/openldap/certs/nti*.pem

echo -e "dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateFile: /etc/openldap/certs/nti310ldapKey.pem
\n
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/nti310ldapcert.pem" > certs.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif

#Test to see if cert config works
slaptest -u
echo "it works"

unalias cp

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetoroperson/ldif

# Creates group and people structure base

echo -e "dn: dc=nti310,dc=local
dc: nti310
objectClass: top
objectClass: domain
\n
dn: cn=ldapadm,dc=nti310,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager
\n
dn: ou=People,dc=nti310,dc=local
objectClass: organizationalUnit
ou: People
\n
dn: ou=Group,dc=nti310,dc=local
objectClass: organizationalUnit
ou:	Group" > base.ldif


setenforce 0

ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f base.ldif -y /root/ldap_admin_pass

systemctl restart httpd




























































































		












