include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    prowlarr_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["prowlarr","nano"]}' > /tmp/pkg.json
iocage create -n "__PROWLARR_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__PROWLARR_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" allow_mlock="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and apply any updates
iocage exec __PROWLARR_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __PROWLARR_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __PROWLARR_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __PROWLARR_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__PROWLARR_JAIL__
iocage fstab -a __PROWLARR_JAIL__ __APPS_ROOT__/__PROWLARR_JAIL__ /config nullfs rw 0 0

# Configure Prowlarr service
iocage exec __PROWLARR_JAIL__ sysrc "prowlarr_enable=YES"
iocage exec __PROWLARR_JAIL__ sysrc prowlarr_data_dir="/config"

# Start service
iocage exec __PROWLARR_JAIL__ service prowlarr start
echo Please open your web browser to http://__PROWLARR_IP__:8191
