#modified 1/9/20
#35.223.168.76/phpPgAdmin/
## user : pgdbuser
## Password : pgdbpass
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


yum -y install python2-pip python3-pip python3-devel python2-devel gcc postgresql-server postgresql-devel postgresql-contrib git
git clone https://github.com/Eli-Brown/Hello-NTI-310-2020.git

postgresql-setup initdb
systemctl start postgresql

sed -i 's,host    all             all             127.0.0.1/32            ident,host    all             all             127.0.0.1/32            md5,g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's,host    all             all             ::1/128                 ident,host    all             all             ::1/128                 md5,g' /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql
systemctl enable postgresql

sudo -u postgres /bin/psql -f /tmp/tempfile

echo "alter user postgres superuser;
CREATE DATABASE nti310;
CREATE USER nti310user WITH PASSWORD 'password';
ALTER ROLE nti310user SET client_encoding TO 'utf8';
ALTER ROLE nti310user SET default_transaction_isolation TO 'read committed';
ALTER ROLE nti310user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE nti310 TO nti310user;" > /tmp/tempfile


sudo -u postgres /bin/psql -f /tmp/tempfile
yum install -y httpd
systemctl enable httpd
systemctl start httpd
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on
sudo yum install -y php php-pgsql
sudo yum install -y mod_ssl


sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
sed -i 's/#port = 5432/port = 5432/g' /var/lib/pgsql/data/postgresql.conf 


		#create CREATE DATABASE mypgdb OWNER pgdbuser
echo "CREATE USER pgdbuser CREATEDB ENCRYPTED PASSWORD 'pgdbpass';
CREATE DATABASE mypgdb OWNER pgdbuser;
GRANT ALL PRIVILEGES ON DATABASE mypgdb TO pgdbuser;" > /tmp/phpmyadmin

sudo -u postgres /bin/psql -f /tmp/phpmyadmin
		# install packages from website
yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-8-x86_64/phpPgAdmin-5.6-11.rhel8.noarch.rpm
systemctl restart httpd




sed -i 's/Require local/Require all granted/g' /etc/httpd/conf.d/phpPgAdmin.conf
sed -i 's/Deny from all/Allow from all/g' /etc/httpd/conf.d/phpPgAdmin.conf
sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf['servers'][0]['host'] = 'localhost';/g" /etc/phpPgAdmin/config.inc.php-dist
sed -i "s/$conf\['owned_only'\] = false;/$conf['owned_only'] = true;/g" /etc/phpPgAdmin/config.inc.php-dist
cp /etc/phpPgAdmin/config.inc.php-dist /etc/phpPgAdmin/config.inc.phpsyst

##35.223.168.76/phpPgAdmin/
## user : pgdbuser
## Password : pgdbpass
