connect-container-to-runtime-socket.pp: connect-container-to-runtime-socket.mod
	semodule_package -m connect-container-to-runtime-socket.mod -o connect-container-to-runtime-socket.pp

connect-container-to-runtime-socket.mod:  connect-container-to-runtime-socket.te
	checkmodule -m connect-container-to-runtime-socket.te -o connect-container-to-runtime-socket.mod
