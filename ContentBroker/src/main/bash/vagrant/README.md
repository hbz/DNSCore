# dns-vagrant
Die Skripte installieren eine CI - CentOS7 Box mit GUI (über RDP) und shared
Folder zum einfachen Datenaustausch.

Eclipse bitte selber installieren.

vagrant 2.2.3 (2.1.2) ist zu installiereren.

## 1a CNTLM-Proxy  
Entweder mittels CNTML Server auf Winows, als Vordergrundprozess

cntnlm.bat:
+ SETX http_proxy http://localhost:3128
+ SETX https_proxy http://localhost:3128
+ cntlm -f -c cntlm.ini

## 1b ENV-VARS Proxy 
Oder: Als alternative Lösung: setzen der folgenden Variablen:
+ set VAGRANT_HTTP_PROXY="http://danr...vrintern.lvr.de:8080/"
+ set HTTP_PROXY="http://danr...vrintern.lvr.de:8080/"
+ set VAGRANT_HTTPS_PROXY="http://danr...vrintern.lvr.de:8080/"
+ set HTTPS_PROXY="http://danr...vrintern.lvr.de:8080/"


## 2 Vagrant Plugins
vagrant plugins:

+ vagrant plugin install vagrant-proxyconf
+ vagrant plugin install vagrant-vbguest

## 3 Box hochfahren und nutzen
+ vagrant up (--provider=virtualbox)
+ vagrant ssh

## 4 Neustart der Box
+ vagrant halt
+ vagrant up

## 5 DNS CI installieren
+ cd /vagrant
+ sudo ./installDNS.sh

## 6 Maven CI Tests als irods starten
+ sudo bash
+ su - irods

## 7 Über dns-vagrant

Über das Vagrantfile wird zur Erzeugung einer VirtualBox das Skript bootstrap.sh mit root-Rechten aufgerufen. Das Skript ruft seinerseits die Skripte regal-bootstrap.sh und dns-bootstrap.sh auf.

Beide Skripte, regal-bootstrap.sh und dns-bootstrap.sh, benötigen eine Reihe von Komponenten, die nich über yum installiert werden. Diese Komponenten werden in bin Verzeichnis heruntergeladen. Alternativ können die Komponenten auch vor dem Aufruf von vagrant up in das bin Verzeichnis kopiert werden. Dies spart dann Download-Zeiten beim wiederholten ausführen von vagrant up oder vagrant provision.

Das skript regal-bootstrap.sh installiert u.a. folgende Komponenten

- Java
- Maven
- Git
- Wget
- Apache2 (httpd)
- fedora
- elasticsearch

Außerdem legt regal-bootstrap.sh ein Installationsverzeichnis /opt/regal an und nimmt die Konfiguration des Apache-Webservers vor. Nach der Installation findet sich unter /vagrant/start-regal.sh ein Startskript mit dem die Regal-Komponenten im Developermode gestartet werden können.

Das Skript dns-bootstrap.sh wird die DNS Software installiert. Das Skript installiert u.a. folgende Komponenten

- postgres
- IRODS
- ImageMagick
- Tomcat
- Clamav
- EPEL
- Gradle
- Grails

Außerdem legt dns-bootstrap.sh ein Installationsverzeichnis /ci an, in dem alle Eigenentwicklungen und Daten abgelegt werden. 


