#-------- M4 Defined Variables
NFS_ENDPOINT='nfs_endpoint'
NFS_PATH='nfs_path'

#-------- More sysctl
mv sys-pagecache.conf /etc/sysctl.d/pagecache.conf

#-------- NFS
zypper --non-interactive install nfs-client
cat >> /etc/fstab <<-EOF
	$NFS_ENDPOINT:$NFS_PATH	/mnt	nfs	defaults,_netdev,nofail,nconnect=16	0	0
	/mnt/container-volumes	/var/magisystem	none	bind,nofail,X-mount.mkdir	0	0
EOF
