#!/usr/bin/bash
set -ex
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 all/etc/ balthasar/etc/ balthasar:/etc
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 --delete-delay all/containers/ balthasar/containers/ balthasar:/etc/containers/systemd
rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 balthasar/config/ balthasar:/etc/magisystem
ssh balthasar sudo systemctl daemon-reload
ssh balthasar bash <<-'EOF'
  export SOPS_AGE_KEY_FILE="$XDG_CONFIG_HOME/sops/age/keys.txt"
  sudo --preserve-env=SOPS_AGE_KEY_FILE find /etc/magisystem -type f -exec bash -c 'grep '\'sops\'\ \'{}\'' && sops decrypt -i '\'{}\' \;
EOF
