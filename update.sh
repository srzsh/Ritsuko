#!/usr/bin/bash
set -ex

function setup-host {
  REMOTE_HOST_NAME="$1"
  rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 all/etc/ "$REMOTE_HOST_NAME"/etc/ "$REMOTE_HOST_NAME":/etc
  rsync -avuP --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 --delete-delay all/containers/ "$REMOTE_HOST_NAME"/containers/ "$REMOTE_HOST_NAME":/etc/containers/systemd
  rsync -avuPL --rsync-path 'sudo rsync' --usermap=1000:0 --groupmap=1000:0 "$REMOTE_HOST_NAME"/config/ "$REMOTE_HOST_NAME":/etc/magisystem
  ssh "$REMOTE_HOST_NAME" sudo systemctl daemon-reload
  ssh "$REMOTE_HOST_NAME" bash <<-'EOF'
    export SOPS_AGE_KEY_FILE="$XDG_CONFIG_HOME/sops/age/keys.txt"
    sudo --preserve-env=SOPS_AGE_KEY_FILE find /etc/magisystem -type f -exec bash -c 'grep '\'sops\'\ \'{}\'' && sops decrypt -i '\'{}\' \;
EOF
}

if [ -z ${1:+set} ]; then
  setup-host balthasar
  setup-host ayanami
else
  setup-host "$1"
fi
