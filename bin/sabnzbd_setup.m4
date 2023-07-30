include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    sabnzbd_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["sabnzbd","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "__SABNZBD_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__SABNZBD_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and apply any updates
iocage exec __SABNZBD_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __SABNZBD_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __SABNZBD_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __SABNZBD_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__SABNZBD_JAIL__
iocage fstab -a __SABNZBD_JAIL__ __APPS_ROOT__/__SABNZBD_JAIL__ /config nullfs rw 0 0
iocage fstab -a __SABNZBD_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__  nullfs rw 0 0

# Configure Sabnzbd service
iocage exec __SABNZBD_JAIL__ sysrc sabnzbd_enable=YES
iocage exec __SABNZBD_JAIL__ sysrc sabnzbd_conf_dir="/config"
iocage exec __SABNZBD_JAIL__ sysrc sabnzbd_user=media
iocage exec __SABNZBD_JAIL__ sysrc sabnzbd_group=media

# Fix Permissions
iocage exec __SABNZBD_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec __SABNZBD_JAIL__ "pw groupmod media -m _sabnzbd"
iocage exec __SABNZBD_JAIL__ mkdir -p /__MOUNT_LOCATION__/downloads/__SABNZBD_FILES__/incomplete
iocage exec __SABNZBD_JAIL__ mkdir /__MOUNT_LOCATION__/downloads/__SABNZBD_FILES__/complete
iocage exec __SABNZBD_JAIL__ chown -R __MEDIA_USER__:__MEDIA_GROUP__ /__MOUNT_LOCATION__/downloads/__SABNZBD_FILES__ /config

# Update Sabnzbd configuration
iocage exec __SABNZBD_JAIL__ service sabnzbd start
iocage exec __SABNZBD_JAIL__ service sabnzbd stop
iocage exec __SABNZBD_JAIL__ sed -i '' -e 's?host = 127.0.0.1?host = 0.0.0.0?g' /config/sabnzbd.ini
iocage exec __SABNZBD_JAIL__ sed -i '' -e 's?download_dir = Downloads/incomplete?download_dir = /__MOUNT_LOCATION__/downloads/__SABNZBD_FILES__/incomplete?g' /config/sabnzbd.ini
iocage exec __SABNZBD_JAIL__ sed -i '' -e 's?complete_dir = Downloads/complete?complete_dir = /__MOUNT_LOCATION__/downloads/__SABNZBD_FILES__/complete?g' /config/sabnzbd.ini

# Start service
iocage exec __SABNZBD_JAIL__ service sabnzbd start
echo Please open your browser to: http://__SABNZBD_IP__:8080/sabnzbd/
