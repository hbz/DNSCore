sudo yum -y update
sudo yum -y groupinstall "X Window System"
sudo yum -y groupinstall "GNOME Desktop" 
sudo yum -y groupinstall "Graphical Administration Tools"
sudo yum -y update
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install xrdp tigervnc-server x11vnc
sudo systemctl enable xrdp
sudo systemctl start xrdp
sudo chcon --type=bin_t /usr/sbin/xrdp
sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
sudo yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd
sudo yum install -y ffmpeg ImageMagick-6.7.8.9 ghostscript sox HandBrake-cli python git
sudo yum install -y tomcat tomcat-webapps
sudo yum remove postgresql\* -y
sudo yum -y install postgresql93-server postgresql93-contrib postgresql93-devel postgresql93-libs postgresql93-odbc pgadmin3_93.x86_64 --nogpgcheck
sudo /usr/pgsql-9.3/bin/postgresql93-setup initdb
sudo systemctl stop postgresql-9.3
sudo systemctl start postgresql-9.3
sudo yum -y install perl-JSON python-jsonschema python-requests python-psutil authd


