Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", type: "9p"

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 1024*4
  end

  config.vm.define "hetzner" do |node|
    node.vm.box = "debian/bookworm64"
    node.vm.hostname = "hetzner"
    node.vm.provider :libvirt do |libvirt|
      libvirt.storage :file, device: "vdb", size: "40G"
    end
    node.vm.provision :shell, inline: <<~'EOS'
      sudo apt-get -y update && sudo apt-get -y install parted
      sudo bash /vagrant/os-provisioning-scripts/install_ignition_hetzner.sh /dev/vdb
    EOS
  end

  (1..2).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "opensuse/Tumbleweed.x86_64"
      node.vm.hostname = "node-#{i}"
      node.vm.provision :shell, inline: <<~'EOS'
        sudo zypper --non-interactive install podman
      EOS
    end
  end
end
