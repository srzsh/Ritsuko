snapperd_snapshot_var.pp: snapperd_snapshot_var.mod
	semodule_package -m snapperd_snapshot_var.mod -o snapperd_snapshot_var.pp

snapperd_snapshot_var.mod:  snapperd_snapshot_var.te
	checkmodule -m snapperd_snapshot_var.te -o snapperd_snapshot_var.mod
