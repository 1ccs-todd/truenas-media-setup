include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    lidarr_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["lidarr","nano"]}' > /tmp/pkg.json
iocage create -n "__LIDARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__LIDARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" allow_mlock="1" boot="on"
rm /tmp/pkg.json

# Update to ratest repo and apply any updates
iocage exec __LIDARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __LIDARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __LIDARR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __LIDARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__LIDARR_JAIL__
iocage fstab -a __LIDARR_JAIL__ __APPS_ROOT__/__LIDARR_JAIL__ /config nullfs rw 0 0
iocage fstab -a __LIDARR_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

# Configure Lidarr service
iocage exec __LIDARR_JAIL__ sysrc lidarr_enable=YES
iocage exec __LIDARR_JAIL__ sysrc "lidarr_data_dir=/config"
iocage exec __LIDARR_JAIL__ sysrc lidarr_user=media
iocage exec __LIDARR_JAIL__ sysrc lidarr_group=media

# Fix Permissions
iocage exec __LIDARR_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec __LIDARR_JAIL__ "pw groupmod media -m lidarr"
iocage exec __LIDARR_JAIL__ chown -R media:media /usr/local/share/lidarr /config

# Start service
iocage exec __LIDARR_JAIL__ service lidarr start
echo Please open your web browser to http://__LIDARR_IP__:8686
