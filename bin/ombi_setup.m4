include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    ombi_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["ca_root_nss","unzip","sqlite3","nano"]}' > /tmp/pkg.json
iocage create -n "__OMBI_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__OMBI_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" allow_mlock="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and apply any updates
iocage exec __OMBI_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __OMBI_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __OMBI_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __OMBI_JAIL__ mkdir /config
mkdir -p __APPS_ROOT__/__OMBI_JAIL__
iocage fstab -a __OMBI_JAIL__ __APPS_ROOT__/__OMBI_JAIL__ /config nullfs rw 0 0

# Download Ombi
iocage exec __OMBI_JAIL__ "fetch https://github.com/Thefrank/freebsd-port-sooners/releases/download/20230416/ombi-4.35.18.pkg"
iocage exec __OMBI_JAIL__ "pkg install -y ombi-4.35.18.pkg"
iocage exec __OMBI_JAIL__ rm ombi-4.35.18.pkg

# Configure Ombi service
iocage exec __OMBI_JAIL__ sysrc ombi_enable=YES
iocage exec __OMBI_JAIL__ sysrc "ombi_data_dir=/config"

# Setup database
if [ ! -f __APPS_ROOT__/Ombi.slqite ];then
  iocage exec ombi sqlite3 /config/Ombi.sqlite "create table aTable(field1 int); drop table aTable;"
  iocage exec ombi mkdir -p /config/Backups
fi
iocage exec __OMBI_JAIL__ ln -s /config/Ombi.sqlite /usr/local/share/ombi/Ombi.sqlite
iocage exec __OMBI_JAIL__ ln -s /config/Backups /usr/local/share/ombi/Backups

# Fix Permissions
iocage exec __OMBI_JAIL__ chown -R ombi:ombi /usr/local/ombi /config

# Start service
iocage exec __OMBI_JAIL__ service ombi start
echo Please open your web browser to http://__OMBI_IP__:5000
