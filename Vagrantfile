# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "192.168.10.16"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus   = 1
    vb.memory = 2048
  end

  config.vm.provision "shell" do |s|
    s.path       = "scripts/provision.sh"
    s.privileged = false

    s.args = [
      "--apt-mirrors",      "mirrors.ustc.edu.cn",
      "--docker-mirrors",   "mirrors.ustc.edu.cn/docker-ce",
      "--registry-mirrors", "https://docker.mirrors.ustc.edu.cn/",
      "--go-version",       "1.17.2",
      "--go-proxy",         "https://goproxy.cn,https://goproxy.io,direct",
    ]
  end
end
