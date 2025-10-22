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

# Installing selinux policy to snapshot /var[/magisystem]
semodule -i ./snapperd_snapshot_var.pp
semodule -i ./connect-container-to-runtime-socket.pp

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

cat > /etc/snapper/configs/magisystem <<-EOF
	# subvolume to snapshot
	SUBVOLUME="$SUBVOLUME_PATH"

	# qgroup of the subvolume
	QGROUP=""

	# filesystem type
	FSTYPE="btrfs"

	# fraction of the filesystems space the snapshots may use
	SPACE_LIMIT="0.5"

	# fraction of the filesystems space that should be free
	FREE_LIMIT="0.2"

	# users and groups allowed to work with config
	ALLOW_USERS=""
	ALLOW_GROUPS=""

	# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
	# directory
	SYNC_ACL="no"

	# start comparing pre- and post-snapshot in background after creating
	# post-snapshot
	BACKGROUND_COMPARISON="yes"

	# run daily number cleanup
	NUMBER_CLEANUP="yes"

	# limit for number cleanup
	NUMBER_MIN_AGE="0"
	NUMBER_LIMIT="0"
	NUMBER_LIMIT_IMPORTANT="10"

	# create hourly snapshots
	TIMELINE_CREATE="yes"

	# cleanup hourly snapshots after some time
	TIMELINE_CLEANUP="yes"

	# limits for timeline cleanup
	TIMELINE_MIN_AGE="1800"
	TIMELINE_LIMIT_HOURLY="6"
	TIMELINE_LIMIT_DAILY="2"
	TIMELINE_LIMIT_WEEKLY="0"
	TIMELINE_LIMIT_MONTHLY="0"
	TIMELINE_LIMIT_YEARLY="0"

	# cleanup empty pre-post-pairs
	EMPTY_PRE_POST_CLEANUP="yes"

	# limits for empty pre-post-pair cleanup
	EMPTY_PRE_POST_MIN_AGE="0"
EOF

sed -i '/^SNAPPER_CONFIGS/s/"\(.*\)"/"\1 magisystem"/' /etc/sysconfig/snapper
snapper --no-dbus -c magisystem setup-quota

umount /var
sed -i \
	-e '/^BTRFS_BALANCE_MOUNTPOINTS/s$"\(.*\)"$"\1:/var"$' \
	-e '/^BTRFS_BALANCE_\(D\|M\)USAGE/s/".*"/"50"/' /etc/sysconfig/btrfsmaintenance

mkdir -p /etc/systemd/system/snapper-cleanup.timer.d
cat > /etc/systemd/system/snapper-cleanup.timer.d/schedule.conf <<-EOF
	[Timer]
	OnUnitActiveSec=1h
EOF
