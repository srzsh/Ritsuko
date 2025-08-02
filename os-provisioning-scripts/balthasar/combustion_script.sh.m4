#-------- M4 Defined Variables
NEW_SSH_PORT='new_ssh_port'

#-------- SELinux
zypper --non-interactive install policycoreutils policycoreutils-python-utils

# Add port to selinux and change sshd port
semanage port --add -t ssh_port_t -p tcp "$NEW_SSH_PORT"
cat > /etc/ssh/sshd_config.d/90-change-port.conf <<-EOF
	# Changing the ssh port
	Port $NEW_SSH_PORT
EOF

# Installing selinux policy to snapshot /var[/container-volumes]
semodule -i ./snapperd_snapshot_var.pp

zypper --non-interactive remove -u policycoreutils-python-utils

#-------- BTRFS + Snapper
# Mounting the correct subvolume
mount /var

# Creating subvolume and adding config to snapper
SUBVOLUME_PATH="/var/magisystem"
btrfs -q subvolume create "$SUBVOLUME_PATH"
btrfs -q property set "$SUBVOLUME_PATH" compression zstd
btrfs quota enable "$SUBVOLUME_PATH"
chown --reference="$HOME_FOLDER" "$SUBVOLUME_PATH"
btrfs -q subvolume create "${SUBVOLUME_PATH}/.snapshots"

cp ./container-volumes /etc/snapper/configs/container-volumes

umount /var
sed -i '/^SNAPPER_CONFIGS/s/"\(.*\)"/"\1 container-volumes"/' /etc/sysconfig/snapper

sed -i \
	-e '/^BTRFS_BALANCE_MOUNTPOINTS/s$"\(.*\)"$"\1:/var"$' \
	-e '/^BTRFS_BALANCE_\(D\|M\)USAGE/s/".*"/"50"/' /etc/sysconfig/btrfsmaintenance

mkdir -p /etc/systemd/system/snapper-cleanup.timer.d
cat > /etc/systemd/system/snapper-cleanup.timer.d/schedule.conf <<-EOF
	[Timer]
	OnUnitActiveSec=1h
EOF
