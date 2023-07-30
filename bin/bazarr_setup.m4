include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    bazarr_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["bazarr","nano"]}' > /tmp/pkg.json
iocage create -n "__BAZARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__BAZARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and check for updates
iocage exec __BAZARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __BAZARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __BAZARR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __BAZARR_JAIL__ mkdir /config
mkdir -p __APPS_ROOT__/__BAZARR_JAIL__
iocage fstab -a __BAZARR_JAIL__ __APPS_ROOT__/__BAZARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __BAZARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Configure Bazarr service
iocage exec __BAZARR_JAIL__ sysrc bazarr_enable=YES
iocage exec __BAZARR_JAIL__ sysrc "bazarr_datadir=/config"
iocage exec __BAZARR_JAIL__ sysrc bazarr_user=media
iocage exec __BAZARR_JAIL__ sysrc bazarr_group=media

# Fix permissions
iocage exec __BAZARR_JAIL__ "pw user add media -c media -u 8675308 -d /nonexistent -s /usr/bin/nologin"
iocage exec __BAZARR_JAIL__ "pw groupmod media -m bazarr"
iocage exec __BAZARR_JAIL__ chown -R media:media /usr/local/share/bazarr /config

# Start service
iocage exec __BAZARR_JAIL__ service bazarr start
echo Please open your web browser to http://__BAZARR_IP__:6767
