# Extract the hostname from the vars file so that it doesn't have to be defined twice
ducc_hostname = File.open("1-vars.sh").grep(/DUCC_HOSTNAME/)[0]
ducc_hostname = ducc_hostname[ducc_hostname.index("=")+1,ducc_hostname.length]
ducc_hostname = ducc_hostname[0,ducc_hostname.index(" ")]
puts "Extracted hostname: #{ducc_hostname} from vars file"

CPU=2
MEM=6144
DISK="100GB"

Vagrant.configure("2") do |config|

  config.vagrant.plugins = ["vagrant-docker-compose", "vagrant-disksize"]

  config.vm.box = "ubuntu/bionic64"
  config.disksize.size = DISK
  config.vm.provider :virtualbox do |v, override|
    v.memory = MEM
    v.cpus = CPU
  end

  # Setup hostname
  config.vm.hostname = ducc_hostname

  # Setup port forwarding for Concourse, Minio, UAA & Credhub
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 9080, host: 9080
  config.vm.network "forwarded_port", guest: 9000, host: 9000
  config.vm.network "forwarded_port", guest: 8008, host: 8008

  # Install Docker & Docker Compose
  config.vm.provision :docker
  config.vm.provision :docker_compose

  # Startup DUCC
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    pushd /vagrant
      source 1-vars.sh
      docker-compose up -d
      docker system prune --volumes -f
    popd
  SHELL

end