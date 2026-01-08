sshd_local_tcp_forwarding.pp: sshd_local_tcp_forwarding.mod
	semodule_package -m sshd_local_tcp_forwarding.mod -o sshd_local_tcp_forwarding.pp

sshd_local_tcp_forwarding.mod: sshd_local_tcp_forwarding.te
	checkmodule -m sshd_local_tcp_forwarding.te -o sshd_local_tcp_forwarding.mod
