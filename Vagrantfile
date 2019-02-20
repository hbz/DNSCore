$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/dns.sh" > "/dev/null" <<EOF
export JAVA_OPTS="-Dhttp.proxyHost=10.0.2.2 -Dhttp.proxyPort=3126"
mkdir -p /ci
EOF
SCRIPT

$set_yum = <<SCRIPT
FILE=/etc/yum.conf
grep -q -x -F 'timeout=700' $FILE || echo 'timeout=700' >> $FILE 
SCRIPT



Vagrant.configure("2") do |config|

  config.proxy.http     = "http://10.0.2.2:3126"
  config.proxy.https    = "http://10.0.2.2:3126"
  config.proxy.no_proxy = "localhost,127.0.0.1"
  config.vm.box = "centos/7"
  config.vm.provision "shell", inline: $set_yum, run: "always"
  config.vm.provision :shell, path: "bootstrap.sh"
  #config.vm.provision "shell", inline: $set_environment_variables, run: "always"  # statt "always" nur "first time" ?
  config.ssh.forward_x11 = true
  #config.vm.synced_folder "D:/Entwicklung/dns/ci", "/ci",type: "virtualbox"
  #config.vm.network "private_network", ip: "192.168.50.5", adapter: 1
  config.vm.network "private_network", ip: "192.168.50.5"
  config.vm.synced_folder ".", "/vagrant",type: "virtualbox"
  config.vm.network "forwarded_port", guest: 9200, host: 9200
  config.vm.network "forwarded_port", guest: 9100, host: 9100
  config.vm.network "forwarded_port", guest: 9001, host: 9001
  config.vm.network "forwarded_port", guest: 9002, host: 9002
  config.vm.network "forwarded_port", guest: 9003, host: 9003
  config.vm.network "forwarded_port", guest: 9004, host: 9004
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.hostname = "cihost"
  
  #config.ssh.insert_key = false
  #config.vm.network :public_network, bridge: 'eth0', ip: '10.25.45.230' #3 bridget adapter 
  
  config.vm.provider "virtualbox" do |v|
     v.memory = 4096
     v.cpus = 3
	 v.name = "dns-ci-vm"
	 
	 if false 
		diskPath = 'D:/workspace/dnsVagrant/developerHomeDisk.vdi'
		unless File.exist?(diskPath)
			v.customize ['createhd', '--filename', diskPath, '--variant', 'Fixed', '--size', 20 * 1024]
		end
	  
		if File.exist?(diskPath)
			#v.customize ['storagectl', :id,'--name', 'SATAController','--add', 'sata','--controller', 'IntelAhci','--portcount', 2]
			#v.customize ['storageattach', :id,  '--storagectl', 'SATAController', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', diskPath]
		end
	end
	 
  end
  
  #config.vm.provision :shell, path: "installDNS.sh"
  
end


