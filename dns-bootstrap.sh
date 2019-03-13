#!/usr/bin/env bash

source /vagrant/variables.conf

function installPackages(){
	sudo yum -y update
	sudo yum -y groupinstall "X Window System"
	sudo yum -y groupinstall "GNOME Desktop" 
	sudo yum -y groupinstall "Graphical Administration Tools"
	sudo yum -y update
	sudo yum -y install xrdp 
        sudo yum -y install tigervnc-server 
        sudo yum -y install x11vnc
	sudo systemctl enable xrdp
	sudo systemctl start xrdp
	sudo chcon --type=bin_t /usr/sbin/xrdp
	sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
	sudo yum -y install clamav-server
	sudo yum -y install clamav-data
	sudo yum -y install clamav-update
	sudo yum -y install clamav-filesystem
	sudo yum -y install clamav
	sudo yum -y install clamav-scanner-systemd
	sudo yum -y install clamav-devel
	sudo yum -y install clamav-lib
	sudo yum -y install clamav-server-systemd
	sudo yum install -y ffmpeg
	sudo yum -y install ImageMagick-6.7.8.9
	sudo yum -y install ghostscript
	sudo yum -y install sox
	sudo yum -y install HandBrake-cli
	sudo yum -y install python
	sudo yum -y install git
	sudo yum install -y tomcat
	sudo yum -y install tomcat-webapps
	sudo yum remove postgresql\* -y
	sudo yum -y install postgresql93-server
	sudo yum -y install postgresql93-contrib
	sudo yum -y install postgresql93-devel
	sudo yum -y install postgresql93-libs
	sudo yum -y install postgresql93-odbc
	sudo yum -y install pgadmin3_93.x86_64 --nogpgcheck
	sudo /usr/pgsql-9.3/bin/postgresql93-setup initdb
	sudo systemctl stop postgresql-9.3
	sudo systemctl start postgresql-9.3
	sudo yum -y install perl-JSON
	sudo yum -y install python-jsonschema
	sudo yum -y install python-requests
	sudo yum -y install python-psutil
	sudo yum -y install authd
}

function download(){
	cd $BIN
	filename=$1
	url=$2
	if [ -f $filename ]
	then
	    echo "$filename is already here! Stop downloading!"
	else
	    wget $server$url
	fi
	cd -
}

function downloadBinaries(){
	server=https://data.danrw.de/download/
	download dns-7-repo.tgz $server
	download epel-release-latest-7.noarch.rpm https://dl.fedoraproject.org/pub/epel/
	download FED-DB-20180517.dump.tgz $server
	download gradle-3.4.1-bin.tgz $server
	download grails-3.2.11.tgz $server
	download irods-database-plugin-postgres-1.11-centos7-x86_64.rpm https://files.renci.org/pub/irods/releases/4.1.11/centos7/
	download irods-icat-4.1.11-centos7-x86_64.rpm https://files.renci.org/pub/irods/releases/4.1.11/centos7/
	download jdk-8u181-linux-x64.rpm $server
	download fedora-files.tgz $server
     	download fedoraNoWar.tgz $server
	download RPM-GPG-KEY-EPEL-7 $server
	download RPM-GPG-KEY-nux $server
}

function checkSystemPrerequisites(){
	if [ -f /etc/redhat-release ] ; then
		export HOSTOS=$(cat /etc/system-release-cpe | cut -f 3 -d : )
		export HOSTREL=$( rpm -qf /etc/redhat-release | cut -f 4,5 -d - | cut -f 1-2 -d .)
		export SYSDVER=$(cat /etc/system-release-cpe | cut -f 5 -d : | cut -c 1)
	else 
		echo "Skript ist nur fuer RedHat-OS angepasst" 
		exit 1;
	fi

	if [ $SYSDVER -ne "7" ] ; then
		echo "Skript ist nur fuer RedHat-OS 7 nicht fuer $SYSDVER" 
		exit 1;
	fi

	if [ ! -d /ci ]; then
	    mkdir /ci
	fi
}

function setLocales(){
	if [ $( localectl | grep "System Locale" | cut -f 2 -d : | cut -f 2 -d = ) != "en_US.UTF-8" ] ; then
		localectl set-locale LANG=en_US.UTF-8
	fi

	export LANG=en_US.UTF-8
}

function shutdownFirewall(){ 
	echo "Fuer die Installation soll die Firewall und IPv6 und SELINUX erst mal abgeschaltet werden."
	if [ `getenforce`=='Enforcing' ] ; then
		setenforce 0
		sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
	fi

	systemctl stop firewalld
	systemctl disable firewalld
	
	ANSWER=`getenforce`	
	if [ $ANSWER != 'Permissive' ] ; then
		echo "Selinux abstellen mislungen: $ANSWER" 
		exit 1;
	fi
}

function installEPEL(){
	if [ $(grep -i "epel" /etc/yum.repos.d/*repo | wc -l ) == "0" ] ; then
		yum -y localinstall $BIN/epel-release-latest-7.noarch.rpm
		rpm --import $BIN/RPM-GPG-KEY-EPEL-7
	fi
}

function installDNS(){	
	cp $BIN/dns-7-repo.tgz /etc/yum.repos.d
	cd /etc/yum.repos.d; 
	tar -xzvf dns-7-repo.tgz
	rpm --import $BIN/RPM-GPG-KEY-nux
	rm -f dns-7-repo.tgz
	yum update

}

function setEnvironmentVariables(){
	if [ ! -f /etc/profile.d/dns.sh ] ; then 
		cp /vagrant/profileDns.sh  /etc/profile.d/dns.sh
	else
		echo  'export FEDORA_HOME=/ci/fedora' >> /etc/profile.d/dns.sh
		echo  'export CATALINA_HOME=/usr/share/tomcat' >> /etc/profile.d/dns.sh
		echo  'export BUILD_NUMBER=123' >> /etc/profile.d/dns.sh
		echo  'export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=256m"' >> /etc/profile.d/dns.sh
		echo  'umask 002 ' >> /etc/profile.d/dns.sh
		echo  ' ' >> /etc/profile.d/dns.sh
	fi
}

function setUpUsers(){
	groupadd -g 401 irods
	groupadd -g 402 postgres   
	groupadd -f -g 403 tomcat
	useradd -c "irods user" -d /home/irods -s /bin/bash -g 401 -u 401 irods
	useradd -c "postgres db user" -d /home/postgres -s /bin/bash -g 402 -u 402 postgres
	useradd -c "tomcat user" -d /home/tomcat -s /bin/bash -g 403 -G 401 -u 403 tomcat
	cat /etc/group | grep ":40"
	cat /etc/passwd | grep ":40"
	groupadd -g 12348 developer
	usermod -a -G developer irods
	groupadd -g 396 elasticsearch
	useradd -c "elasticsearch" -d /usr/share/elasticsearch -s /sbin/nologin -g 396 -u 397 elasticsearch
}

function installJava(){
	java -version
	ls -l /usr/bin/java
	if [ ! -d /usr/java/jdk1.8.0_181-amd64 ] ; then
	   echo "JDK 1.8.0.181 wird installiert."
	   mkdir /usr/java
	   yum localinstall -y $BIN/jdk-8u181-linux-x64.rpm
	fi

	ln -s /usr/java/jdk1.8.0_181-amd64 /usr/java/latest 
	ln -s /usr/java/latest /usr/java/default
	if [ $( rpm -qa | grep -i chkconfig | wc -l ) == "0" ] ; then
		yum -y install chkconfig
	fi
	/usr/sbin/alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_181-amd64/bin/java  3
	/usr/sbin/alternatives --set  java /usr/java/jdk1.8.0_181-amd64/bin/java
	echo "export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64" >> ~irods/.bashrc
	echo "export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64" >> ~tomcat/.bashrc
	echo "export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64" >> /etc/profile.d/dns.sh
	java -version
	ANSWER=$(java -version 2>&1 | head -n 1 | cut -f 3 -d " " )
	echo "java ANSWER: $ANSWER"
}

function checkStateOfInstalledPackages(){
	ANSWER=$(rpm -qa | grep -i ImageMagick )
	echo "ImageMagick ANSWER: $ANSWER"
	ANSWER=$(rpm -qa | grep -i ffmpeg )
	echo "ffmpeg ANSWER: $ANSWER"
	ANSWER=$(rpm -qa | grep -i ghostscript)
	echo "ghostscript ANSWER: $ANSWER"
	ANSWER=$(rpm -qa | grep -i sox )
	echo "sox ANSWER: $ANSWER"
	ANSWER=$(rpm -qa | grep -i handbrake )
	echo "handbrake ANSWER: $ANSWER"
	ANSWER=$(rpm -qa | grep -i tomcat | wc -l )
	echo "tomcat ANSWER: $ANSWER"
}

function configureClamAV(){
	sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf
	sed -i -e "s/^#LocalSocket/LocalSocket/" /etc/clamd.d/scan.conf	
}

function configureTomcat(){
	mkdir /usr/share/tomcat/.grails/
	cp /vagrant/daweb3_properties.groovy /usr/share/tomcat/.grails/daweb3_properties.groovy
	chmod 644 /usr/share/tomcat/.grails/daweb3_properties.groovy
	chown tomcat:tomcat -R /usr/share/tomcat/.grails
}

function configurePostgres(){
	mv /var/lib/pgsql/9.3/data/pg_hba.conf /var/lib/pgsql/9.3/data/pg_hba.confBU
	cp -f /vagrant/pg_hba.conf /var/lib/pgsql/9.3/data/pg_hba.conf
	sed -i "s/#listen_addresses/listen_addresses = '*'\n#listen_addresses/g" /var/lib/pgsql/9.3/data/postgresql.conf 
	sed -i 's/max_connections = 100/max_connections = 200/g' /var/lib/pgsql/9.3/data/postgresql.conf   # TODO: wird nichts ersetzt
	systemctl enable postgresql-9.3
	systemctl stop postgresql-9.3
	systemctl start postgresql-9.3
	mv /etc/odbcinst.ini /etc/odbcinst.orig
	head -n 11 /etc/odbcinst.orig >> /etc/odbcinst.ini
	ANSWER=`ps -ef | grep -i pgsql `
	echo "postgres ANSWER: $ANSWER"
}

function createPostgresDBs(){
	su - postgres -c "/usr/pgsql-9.3/bin/createuser -s -d -r -l irods"
	su - postgres -c "/usr/pgsql-9.3/bin/createuser -s -d -r -l fed_usr"
	su - postgres -c "/usr/pgsql-9.3/bin/createuser -s -d -r -l cb_usr"
	su - postgres -c "/usr/pgsql-9.3/bin/dropdb CB"
	su - postgres -c "/usr/pgsql-9.3/bin/dropdb ICAT"
	su - postgres -c "/usr/pgsql-9.3/bin/dropdb FED"
	su - postgres -c "/usr/pgsql-9.3/bin/createdb -E UTF-8 -O irods CB"
	su - postgres -c "/usr/pgsql-9.3/bin/createdb -E UTF-8 -O irods ICAT"
	su - postgres -c "/usr/pgsql-9.3/bin/createdb -E UTF-8 -O irods FED"
	echo "alter role irods with password '"$FEDPASS"';" > ~postgres/alter-irods-user.sql
	echo "alter role irods with password '"$ICATPASS"';" >> ~postgres/alter-irods-user.sql
	echo "alter role irods with password '"$RODSPASS"';" >> ~postgres/alter-irods-user.sql	
	cp /vagrant/client-encoding-utf8.sql ~postgres
	cp /vagrant/createDB.sql ~postgres
	su - postgres -c "/usr/bin/psql -f ~postgres/alter-irods-user.sql"
	su - postgres -c "/usr/bin/psql -f ~postgres/client-encoding-utf8.sql"
	su - postgres -c "/usr/bin/psql -f ~postgres/createDB.sql"
}

function installFedora(){
	echo "fedora install"
	cd $BIN/ 
	tar -xzf $BIN/FED-DB-20180517.dump.tgz
	psql -d FED -U fed_usr < ./FED-DB-20180517.dump
	rm -f $BIN/FED-DB-20180517.dump
	sleep 1
	echo "fedora unpack tar"
	tar -xzf $BIN/fedora-files.tgz
	if [ -d /ci/fedora ] ; then
		rm -rf /ci/fedora
	fi
	mv fedora /ci/
	chown -R irods:developer /ci/fedora
	rm -rf fedora
	systemctl stop tomcat
	sed -i "s/unpackWARs=\"true\" autoDeploy=\"true\"/unpackWARs=\"true\" autoDeploy=\"false\"/g" /usr/share/tomcat/conf/server.xml 
	cp /vagrant/fedoraTomcatConf.xml /usr/share/tomcat/conf/Catalina/localhost/fedora.xml	
	cd /usr/share/tomcat/webapps/
	if [ -d /usr/share/tomcat/webapps/fedora ] ; then 
		rm -rf /usr/share/tomcat/webapps/fedora;
	fi
	tar -xzf $BIN/fedoraNoWar.tgz
	rm -f fedora.war
	systemctl enable tomcat
	systemctl start tomcat
	sleep 1
}

function prepareIRODSDirectoryLayout(){
	mkdir -p $CACHEDIR/work
	chown -R irods:irods $CACHEDIR
	if [ -d ~irods/.irods ] ; then
		rm -rf  ~irods/.irods 
	fi
	mkdir ~irods/.irods;
	chmod 770 ~irods/.irods
	systemctl stop irods
	yum remove irods\* -y
	rm -rf  /var/lib/irods/
	rm -rf ~irods/.irods
	rm -rf /etc/irods
}

function installIRODS(){
	yum -y localinstall $BIN/irods-icat-4.1.11-centos7-x86_64.rpm
	yum -y localinstall $BIN/irods-database-plugin-postgres-1.11-centos7-x86_64.rpm
	if [ -f /usr/lib64/psqlodbc.so ] ; then	rm -f /usr/lib64/psqlodbc.so  
	fi
	if [ -f /usr/pgsql-9.3/lib/psqlodbc.so ] ; then
		rm -f /usr/pgsql-9.3/lib/psqlodbc.so
	fi
	chown -R irods:irods /var/lib/irods	
	systemctl stop postgresql-9.3
	systemctl start postgresql-9.3
	systemctl stop irods 
}
function configureIRODS(){
	sed -i "s/SHA256/MD5/g" /etc/irods/server_config.json

	if [ -f /etc/init.d/irods ]; then
	    chkconfig irods off
	    service irods stop
	    rm -f /etc/init.d/irods
	fi
	cp /vagrant/irodsC7 /etc/systemd/system/irods.service
	systemctl enable irods
	systemctl start irods
	
	echo "Zone $ZONES"
	
	echo "Zonenkey $ZONEKEY"
	echo "Default-Dir $CACHEDIR"
	printf "irods\nirods\n$ZONENAME\n1247\n\n\n$CACHEDIR\ndns$ZONES\n$ZONEKEY\n1248\ndnszone-dnszone-dnszone-dnszone-\noff\nrods\n$RODSPASS\nyes\nlocalhost\n\n\n\n$ICATPASS\nyes\n" | /var/lib/irods/packaging/setup_irods.sh
	sleep 3
	systemctl start irods 
	sleep 1
	sed -i 's!\"default_dir_mode\": \"0750\"!\"default_dir_mode\": \"0775\"!g' /etc/irods/server_config.json
	sed -i 's!\"default_file_mode\": \"0600\"!\"default_file_mode\": \"0664\"!g' /etc/irods/server_config.json
	su - irods -c  "printf 'y\n' | /usr/bin/iadmin modresc demoResc name $CACHERESC"
	systemctl stop irods
	sleep 1
	sed -i 's/SHA256/MD5/g' ~irods/.irods/irods_environment.json
	sed -i "s/demoResc/$CACHERESC/g" /etc/irods/server_config.json
	sed -i "s/demoResc/$CACHERESC/g" ~irods/.irods/irods_environment.json
	sed -i "s/demoResc/$CACHERESC/g" /etc/irods/core.re
	service irods start	
}

function createIRODSResources(){
	su - irods -c  "printf 'y\n' | /usr/bin/iadmin mkresc $ARCHRESC unixfilesystem $OWNHOST:$LZAPATH"
	su - irods -c  "printf 'y\n' | /usr/bin/iadmin mkresc $LZARESCG passthru"
	su - irods -c  "printf 'y\n' | /usr/bin/iadmin addchildtoresc $LZARESCG $ARCHRESC" 
	su - irods -c  "printf 'y\n' | /usr/bin/iadmin modresc ciWorkingResource path $WORKDIR"
}

function installElasticsearch(){
	yum -y localinstall $BIN/elasticsearch-0.90.3.noarch.rpm
	sed -i "s/# cluster.name/cluster.name: cluster_ci\n# cluster.name/g" /etc/elasticsearch/elasticsearch.yml
	systemctl restart elasticsearch
	/vagrant/initES.sh "portal_ci_test" 
	/vagrant/initES.sh "portal_ci"
}

function installGradleGrails(){
	mkdir -p /ci/projects; 
	cd /ci/projects
	mkdir -p ~irods/.m2
	cp /vagrant/MavenSettings.xml  ~irods/.m2/settings.xml
	mkdir -p ~/.m2
	cp /vagrant/MavenSettings.xml  ~/.m2/settings.xml
	chown -R irods:irods ~irods/.m2
	ln -s /ci/projects/apache-maven-3.6.0/bin/mvn /usr/bin/mvn
	echo  'export M2_HOME=/ci/projects/apache-maven-3.6.0' >> /etc/profile.d/dns.sh
	echo  'export PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/dns.sh
	cp $BIN/grails-3.2.11.tgz /ci/projects/grails-3.2.11.tgz
	cd /ci/projects/; 
	tar -xzf grails-3.2.11.tgz
	rm -f grails-3.2.11.tgz
	cp $BIN/gradle-3.4.1-bin.tgz /ci/projects/gradle-3.4.1-bin.tgz
	cd /ci/projects/; 
	tar -xzf gradle-3.4.1-bin.tgz
	rm -f gradle-3.4.1-bin.tgz
	chown -R irods:developer /ci/projects/
	ln -s /ci/projects/grails-3.2.11/bin/grails /usr/bin/grails
	ln -s /ci/projects/gradle-3.4.1/bin/gradle /usr/bin/gradle
}

function installContentBroker(){
	mkdir /ci/ContentBroker
	chown irods:developer /ci/ContentBroker
	cd /ci/
	git clone https://github.com/da-nrw/DNSCore.git
}

function createStorageAreas(){
	mkdir -p /ci/storage/IngestArea
	mkdir -p /ci/storage/IngestArea/noBagit
	mkdir -p /ci/storage/IngestArea/noBagit/TEST
	mkdir -p /ci/storage/IngestArea/TEST
	mkdir -p /ci/storage/WorkArea
	mkdir -p /ci/storage/UserArea
	mkdir -p /ci/storage/GridCacheArea
	mkdir -p /ci/storage/UserArea/TEST
	mkdir -p /ci/storage/UserArea/rods
	mkdir -p /ci/storage/UserArea/TEST/incoming
	mkdir -p /ci/storage/UserArea/TEST/outgoing
	chown -R irods:developer /ci/DNSCore
	chown -R irods:developer /ci/storage
}

function linkPythonToCI(){
	mkdir -p /ci/python/
	ln -s /usr/bin/python2.7 /ci/python/python
}

OWNHOST=$(hostname -s)
ZONENAME="ci"
HOSTNR=1
RODSPASS="sdor78-bvc"
ICATPASS="irods123"
FEDPASS="clBDmno7"
CACHEDIR="/ci/archiveStorage"
WORKDIR="/ci/storage/WorkArea"
CACHERESC="ciWorkingResource"
DBPASS="KKLmno13g"
ARCHRESC="ciArchiveResource"
LZAPATH="/ci/archiveStorage"
LZARESCG="ciArchiveRescGroup"
ZONES="12345"	
ZONEKEY="dns"$ZONES"dns"$ZONES"dns"$ZONES"dns"$ZONES

#Preparations
checkSystemPrerequisites
setLocales
shutdownFirewall
#Create users and install directory
setUpUsers
setEnvironmentVariables
createStorageAreas
prepareIRODSDirectoryLayout
#Download third party software
downloadBinaries
#Install
installPackages
installEPEL
installDNS
#installJava
configureClamAV
configureTomcat
configurePostgres
createPostgresDBs     
#installFedora
installIRODS
configureIRODS
createIRODSResources
#installElasticsearch
installGradleGrails
installContentBroker
linkPythonToCI
chmod -R g+w /ci
#Report
checkStateOfInstalledPackages
#cd /ci/DNSCore
#iusrcmd "mvn install -Pci"

