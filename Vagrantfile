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
      apt-get -y update && sudo apt-get -y install parted
      bash /vagrant/os-provisioning-scripts/install_ignition_hetzner.sh /dev/vdb
      mount /dev/vdb5 /mnt
      mkdir /mnt/combustion
      cp /vagrant/os-provisioning-scripts/balthasar/files/* /mnt/combustion
      # umount /mnt
    EOS
  end

  (1..2).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "opensuse/Tumbleweed.x86_64"
      node.vm.hostname = "node-#{i}"
      node.vm.provision :shell, inline: <<~'EOS'
        zypper --non-interactive dup
        zypper --non-interactive install podman
        HOSTNAME="$(cat /etc/hostname)"
        mkdir -p /etc/magisystem
        cp -Pru /vagrant/all/etc/* /etc
        cp -Pu /vagrant/all/containers/* /etc/containers/systemd
        cp -Pru /vagrant/"$HOSTNAME"/etc/* /etc
        cp -Pu /vagrant/"$HOSTNAME"/containers/* /etc/containers/systemd
        cp -Pru /vagrant/"$HOSTNAME"/config/* /etc/magisystem
        systemctl daemon-reload
        systemctl enable --now podman.socket
        mkdir -p /var/magisystem
      EOS
    end
  end

  config.vm.define "node-1" do |node|
    node.vm.hostname = "balthasar"
  end

  config.vm.define "node-2" do |node|
    node.vm.hostname = "ayanami"
  end
end
