$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/dns.sh" > "/dev/null" <<EOF

mkdir -p /ci
EOF
SCRIPT

$set_yum = <<SCRIPT
FILE=/etc/yum.conf
grep -q -x -F 'timeout=700' $FILE || echo 'timeout=700' >> $FILE 
SCRIPT



Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.provision "shell", inline: $set_yum, run: "always"
  config.vm.provision :shell, path: "bootstrap.sh"
  #config.vm.provision "shell", inline: $set_environment_variables, run: "always"  # statt "always" nur "first time" ?
  config.ssh.forward_x11 = true
  #config.vm.synced_folder "D:/Entwicklung/dns/ci", "/ci",type: "virtualbox"
  #config.vm.network "private_network", ip: "192.168.50.5", adapter: 1
  config.vm.network "private_network", ip: "192.168.50.5"
  config.vm.synced_folder ".", "/vagrant",type: "virtualbox"
#  config.vm.network "forwarded_port", guest: 9200, host: 9200
#  config.vm.network "forwarded_port", guest: 9100, host: 9100
#  config.vm.network "forwarded_port", guest: 9001, host: 9001
#  config.vm.network "forwarded_port", guest: 9002, host: 9002
#  config.vm.network "forwarded_port", guest: 9003, host: 9003
#  config.vm.network "forwarded_port", guest: 9004, host: 9004
#  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.hostname = "cihost"
  
  #config.ssh.insert_key = false
  #config.vm.network :public_network, bridge: 'eth0', ip: '10.25.45.230' #3 bridget adapter 
  
  config.vm.provider "virtualbox" do |v|
     v.memory = 4096
     v.cpus = 3
	 v.name = "dns-ci-vm"	 
  end
  
  #config.vm.provision :shell, path: "installDNS.sh"
  
end


