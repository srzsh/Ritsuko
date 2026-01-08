#!/usr/bin/bash
set -ex
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 all/etc/ balthasar/etc/ magisystem:/etc
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 --delete-delay all/containers/ balthasar/containers/ magisystem:/etc/containers/systemd
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 balthasar/config/ magisystem:/etc/magisystem
ssh magisystem sudo systemctl daemon-reload
ssh magisystem bash <<-'EOF'
  export SOPS_AGE_KEY_FILE="$XDG_CONFIG_HOME/sops/age/keys.txt"
  sudo --preserve-env=SOPS_AGE_KEY_FILE find /etc/magisystem -type f -exec bash -c 'grep '\''"sops": {'\'\ \'{}\'' && sops decrypt -i '\'{}\' \;
EOF
