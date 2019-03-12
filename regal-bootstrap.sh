#!/usr/bin/env bash

source /vagrant/variables.conf

function downloadPackages(){
	cd /vagrant

	if [ -f typesafe-activator-1.3.5.zip ]
	then
	    echo "Activator is already here! Stop downloading!"
	else
	    wget http://downloads.typesafe.com/typesafe-activator/1.3.5/typesafe-activator-1.3.5.zip
	fi

	if [ -f fcrepo-installer-3.7.1.jar ]
	then
	    echo "fcrepo is already here! Stop downloading!"
	else
	    wget http://sourceforge.net/projects/fedora-commons/files/fedora/3.7.1/fcrepo-installer-3.7.1.jar 
	fi

	if [ -f mysql-community-release-el7-5.noarch.rpm ]
	then
	    echo "Mysql is already here! Stop downloading!"
	else
	    wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm 
	fi

	if [ -f elasticsearch-1.1.0.noarch.rpm ]
	then
	    echo "Elasticsearch is already here! Stop downloading!"
	else
	    wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.1.0.noarch.rpm
	fi
}

function installPackages(){
    sudo yum -y update
    sudo yum -y install httpd
    sudo yum -y install git
    sudo yum -y install java-1.8.0-openjdk-devel
    sudo yum -y install maven
    sudo yum -y install wget
    sudo yum -y install curl
    sudo yum -y install emacs
    sudo yum -y install unzip
    
    
    yes|sudo rpm -ivh /vagrant/mysql-community-release-el7-5.noarch.rpm
    yum update -y
    sudo yum -y install mysql-server
    sudo systemctl start mysqld

    
    sudo rpm -i /vagrant/elasticsearch-1.1.0.noarch.rpm
    cd /usr/share/elasticsearch/
    sudo bin/plugin -install mobz/elasticsearch-head
    sudo bin/plugin install elasticsearch/elasticsearch-analysis-icu/2.1.0
    sudo bin/plugin -install com.yakaz.elasticsearch.plugins/elasticsearch-analysis-combo/1.5.1
    sudo echo "cluster.name: danrw-dev" > /etc/elasticsearch/elasticsearch.yml
}

function createRegalFolderLayout(){
    sudo mkdir $ARCHIVE_HOME
    sudo chown -R vagrant $ARCHIVE_HOME
    sudo su -l vagrant
    mkdir  $ARCHIVE_HOME/src
    mkdir  $ARCHIVE_HOME/apps
}

function downloadRegalSources(){
    cd $ARCHIVE_HOME/src
    git clone https://github.com/edoweb/regal-api 
    cp /vagrant/application.conf $ARCHIVE_HOME/src/regal-api/conf/application.conf
    git clone https://github.com/edoweb/regal-install
    git clone https://github.com/hbz/thumby
    git clone https://github.com/hbz/etikett
    git clone https://github.com/hbz/zettel
    git clone https://github.com/hbz/skos-lookup
}

function installFedora(){
    /vagrant/configure.sh
    export FEDORA_HOME=$ARCHIVE_HOME/fedora
    java -jar /vagrant/fcrepo-installer-3.7.1.jar  $ARCHIVE_HOME/conf/install.properties
    cp $ARCHIVE_HOME/conf/fedora-users.xml $ARCHIVE_HOME/fedora/server/config/
    cp $ARCHIVE_HOME/conf/setenv.sh $ARCHIVE_HOME/fedora/tomcat/bin
    cp $ARCHIVE_HOME/conf/tomcat-users.xml /opt/regal/fedora/tomcat/conf/
}

function installPlay(){
    cd $ARCHIVE_HOME/src/regal-install
  
    if [ -d $ARCHIVE_HOME/activator-1.3.5 ]
    then
	echo "Activator already installed!"
    else
	unzip /vagrant/typesafe-activator-1.3.5.zip -d $ARCHIVE_HOME 
    fi
}

function postProcess(){
    ln -s  $ARCHIVE_HOME/activator-dist-1.3.5  $ARCHIVE_HOME/activator
    mv  $ARCHIVE_HOME/proai/  $ARCHIVE_HOME/apps
    sudo chown -R vagrant $ARCHIVE_HOME
}

function installRegalModule(){
    VERSION=$1
    APPNAME=$2
    $ARCHIVE_HOME/activator/activator clean
    yes r|$ARCHIVE_HOME/activator/activator dist
    $ARCHIVE_HOME/activator/activator eclipse
    cp target/universal/$VERSION.zip  /tmp
    cd /tmp
    unzip $VERSION.zip
    mv $VERSION  $ARCHIVE_HOME/apps/$APPNAME
}

function installRegalModules(){
    cd  $ARCHIVE_HOME/src/thumby;
    installRegalModule thumby-0.1.0-SNAPSHOT thumby

    cd  $ARCHIVE_HOME/src/skos-lookup
    installRegalModule skos-lookup-1.0-SNAPSHOT skos-lookup

    cd  $ARCHIVE_HOME/src/etikett
    installRegalModule etikett-0.1.0-SNAPSHOT etikett

    cd  $ARCHIVE_HOME/src/zettel
    installRegalModule zettel-1.0-SNAPSHOT zettel

    cd  $ARCHIVE_HOME/src/regal-api
    installRegalModule regal-api-0.8.0-SNAPSHOT  regal-api
}

function configureRegalModules(){
    mysql -u root -Bse "CREATE DATABASE etikett  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;CREATE USER 'etikett'@'localhost' IDENTIFIED BY 'etikett';GRANT ALL ON etikett.* TO 'etikett'@'localhost';"
}

function configureApache(){
    /usr/sbin/setsebool -P httpd_can_network_connect 1
    sed -i "1 s|$| api.localhost|" /etc/hosts
    mkdir /etc/httpd/sites-enabled
    echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
    cp /vagrant/regal.vagrant.conf /etc/httpd/sites-enabled/
}

downloadPackages
installPackages
createRegalFolderLayout
downloadRegalSources
installFedora
installPlay
postProcess
installRegalModules
configureRegalModules
configureApache
sudo chown -R vagrant $ARCHIVE_HOME
