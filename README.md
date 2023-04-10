what is this?

- nixOS configurations for a homelab server & public proxy
- 2 qemu VMs, one @ home and one @ datacenter

home services:

- home rust band webapp
- vaultwarden
- nextcloud

some keys needs provisioned to the servers:

- /var/lib/age/keys.txt

some manual setup for hcc:

- no packaging for clubhouse stuff
- clone repos to /var/lib/holycharisma
- build, run db migrations
- no systemd service for holycharisma server yet
  - currently just using a tmux session

release frontend assets go on caddy proxy server

- get webassembly/js assets into /var/lib/holycharisma/www/hcc
