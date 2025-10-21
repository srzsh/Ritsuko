FROM docker.io/library/alpine

RUN apk add --no-cache wireguard-tools iptables

RUN cat > /docker-entrypoint.sh <<'EOF'
#!/bin/sh
set -e
export CONFIG_NAME="$1"
exec /sbin/init
EOF

RUN cat > /etc/inittab <<'EOF'
::wait:/bin/sh -c 'modprobe wireguard; wg-quick up $CONFIG_NAME'
::shutdown:/bin/sh -c 'wg-quick down $CONFIG_NAME'
EOF

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
