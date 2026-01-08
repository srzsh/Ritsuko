#!/usr/bin/bash
set -ex
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 all/etc/ balthasar/etc/ magisystem:/etc
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 --delete-delay all/containers/ balthasar/containers/ magisystem:/etc/containers/systemd
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 balthasar/config/ magisystem:/etc/magisystem
ssh magisystem sudo systemctl daemon-reload
