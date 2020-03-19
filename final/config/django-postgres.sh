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


#!/bin/bash
#django-centos7

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

# fun django tutorial https://data-flair.training/blogs/django-migrations-and-database-connectivity/
# These are the really tricky sed and perl lines from the handout.  Please see me for the handout.

yum -y install python2-pip python3-pip python3-devel python2-devel gcc postgresql-server postgresql-devel postgresql-contrib
pip install --upgrade pippip install virtualenv
mkdir /opt/nti310
cd /opt/nti310
virtualenv nti310env
source nti310env/bin/activate
pip install django psycopg2
django-admin.py startproject nti310

perl -i -0pe "BEGIN{undef $/;} s/        'ENGINE':.*db.sqlite3'\),/        'ENGINE': 'django.db.backends.postgresql_psycopg2',\n        'NAME': 'nti310',\n        'USER': 'nti310user',\n        'PASSWORD': 'password',\n        'HOST': 'postgres',\n        'PORT': '5432',/smg" /opt/nti310/nti310/settings.py

echo "class Specs(models.Model):
    name = models.CharField(max_length = 20)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    weight = models.PositiveIntegerField()" >> Cars/models.py

#install this on the Postgres sever:
##sed -i "s/host    all             all             127.0.0.1\/32            md5/host    all             all             0.0.0.0\/0               md5/g" /var/lib/pgsql/data/pg_hba.conf


#django admin user creation
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@newproject.com','NTI300NTI300')" | python manage.py shell   


echo "*.info;mail.none;authpriv.none;cron.none   @rsyslog-server" >> /etc/rsyslog.conf && systemctl restart rsyslog.service
#Important: this should be the internal not external IP of the server or the dns name of your server.
