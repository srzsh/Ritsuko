#!/bin/bash
# combustion: network
# Network is needed to install packages

set -ex
 
#-------- M4 Defined Variables
NEW_USER='new_user_name'
NEW_USER_SSH_PUBKEY='new_user_ssh_pubkey'

#-------- Timezone
rm /etc/localtime || true
ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

#-------- Partitions
zypper --non-interactive install parted

# Removing Config partition, Growing SWAP until end of the disk, Growing data partition to fill the empty space
DISK_PATH=$(df --output=source / | tail -n1)
PARTED_OUTPUT=$(parted -s "$DISK_PATH" unit MiB print)
CONFIG_PART_NUMBER=$(printf "$PARTED_OUTPUT" | tail -n 1 | cut -d ' ' -f2)
SWAP_PART=$(printf "$PARTED_OUTPUT" | tail -n 2 | head -n 1)
SWAP_PART_NUMBER=$(printf "$SWAP_PART" | cut -d ' ' -f2)
DATA_PART_NUMBER=$(printf "$PARTED_OUTPUT" | tail -n 3 | head -n 1 | cut -d ' ' -f2)
DATA_PART_END=$(($(printf "$SWAP_PART" | tr -s ' ' | cut -d ' ' -f 3 | tr -d 'MiB')-1))
#TODO: Use sfdisk/sgdisk
parted -s "$DISK_PATH" rm "$CONFIG_PART_NUMBER" || true
parted -s "$DISK_PATH" resizepart "$SWAP_PART_NUMBER" 100% || true
parted -s "$DISK_PATH" resizepart "$DATA_PART_NUMBER" "${DATA_PART_END}MiB" || true
#TODO: Resize btrfs filesystem
btrfs filesystem resize max /
partprobe "$DISK_PATH" && udevadm settle

# Adding swap to fstab
#TODO: Filter by disk before looking for the swap partition
printf "UUID=$(blkid | grep 'TYPE="swap"' | sed 's/.* UUID="\([a-zA-Z0-9-]*\)".*/\1/') none swap defaults 0 0" >> /etc/fstab

zypper --non-interactive remove -u parted

#-------- User/Authentication
# Mount home subvolume
mount /home

# Create User
useradd --create-home "$NEW_USER"
HOME_FOLDER="/home/$NEW_USER"
SSH_FOLDER="${HOME_FOLDER}/.ssh"
mkdir -pm700 "$SSH_FOLDER"
cat > "${SSH_FOLDER}/authorized_keys" <<<"$NEW_USER_SSH_PUBKEY"
chown -R --reference="$HOME_FOLDER" "$SSH_FOLDER"

#-------- Sudoers + SSHd + Logrotate

cat > /etc/sudoers.d/90-allow-user-nopasswd <<-EOF
	# Allow passwordless sudo to template_user
	$NEW_USER ALL=(ALL:ALL) NOPASSWD: ALL
EOF

echo 'Include /etc/ssh/sshd_config.d/*' >> /etc/ssh/sshd_config
mkdir /etc/ssh/sshd_config.d || true

cat > /etc/ssh/sshd_config.d/40-prohibit-root-login.conf <<-EOF
	# Prohibiting login as root
	PermitRootLogin no
EOF

cat > /etc/ssh/sshd_config.d/40-disable-password-authentication.conf <<-EOF
	# Disable Password and Challenge Authentication
	PasswordAuthentication no
	ChallengeResponseAuthentication no
EOF

systemctl enable sshd.service

sinclude(host_name`/combustion_script.sh.m4')
