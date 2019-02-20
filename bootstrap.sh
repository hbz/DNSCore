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

#sed -i "s/max_bpp=32/max_bpp=24/g" /etc/xrdp/xrdp.ini
#xserverbpp=24
