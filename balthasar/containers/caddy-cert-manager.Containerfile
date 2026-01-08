FROM docker.io/library/caddy:2-builder AS builder

RUN xcaddy build --with github.com/mholt/dhall-adapter

FROM docker.io/library/caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
CMD [ "caddy", "run", "--config", "/etc/caddy/caddy.dhall", "--adapter", "dhall" ]
