include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    jellyfin_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["jellyfin","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "__JELLYFIN_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__JELLYFIN_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" allow_mlock="1" boot="on"
rm /tmp/pkg.json

# Update to the latest repo and apply any updates
iocage exec __JELLYFIN_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __JELLYFIN_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __JELLYFIN_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __JELLYFIN_JAIL__ "mkdir -p /var/db/jellyfin"
mkdir -p __APPS_ROOT__/__JELLYFIN_JAIL__
iocage fstab -a __JELLYFIN_JAIL__ __APPS_ROOT__/__JELLYFIN_JAIL__ /var/db/jellyfin nullfs rw 0 0
iocage fstab -a __JELLYFIN_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs ro 0 0

# Configure Jellyfin service
iocage exec __JELLYFIN_JAIL__ sysrc jellyfin_enable=YES
iocage exec jellyfin sysrc jellyfin_user="media"
iocage exec jellyfin sysrc jellyfin_group="media"

# Fix permissions
iocage exec __JELLYFIN_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec __JELLYFIN_JAIL__ "pw groupmod media -m jellyfin"
iocage exec __JELLYFIN_JAIL__ chown -R media:media /var/db/jellyfin

# Start service
iocage exec __JELLYFIN_JAIL__ service jellyfin start
echo Please open your web browser to http://__JELLYFIN_IP__:8096/
