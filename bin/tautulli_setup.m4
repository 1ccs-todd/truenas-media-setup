include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    tautulli_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Create the jail
echo '{"pkgs":["python2","py27-sqlite3","py27-openssl","git-tiny","py27-pycryptodome","nano"]}' > /tmp/pkg.json
iocage create -n "__TAUTULLI_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TAUTULLI_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to latest repo and apply any updates
iocage exec __TAUTULLI_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __TAUTULLI_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __TAUTULLI_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __TAUTULLI_JAIL__ mkdir /config
mkdir -p __APPS_ROOT__/__TAUTULLI_JAIL__
iocage fstab -a __TAUTULLI_JAIL__ __APPS_ROOT__/__TAUTULLI_JAIL__ /config nullfs rw 0 0

# Download Tautulli
iocage exec __TAUTULLI_JAIL__ git clone https://github.com/Tautulli/Tautulli.git /usr/local/share/Tautulli

# Configure Tautulli service
iocage exec __TAUTULLI_JAIL__ sysrc tautulli_enable=YES
iocage exec __TAUTULLI_JAIL__ sysrc "tautulli_flags=--datadir /config"

# Fix permissions
iocage exec __TAUTULLI_JAIL__ "pw user add tautulli -c tautulli -u 109 -d /nonexistent -s /usr/bin/nologin"
iocage exec __TAUTULLI_JAIL__ chown -R tautulli:tautulli /usr/local/share/Tautulli /config
iocage exec __TAUTULLI_JAIL__ cp /usr/local/share/Tautulli/init-scripts/init.freenas /usr/local/etc/rc.d/tautulli
iocage exec __TAUTULLI_JAIL__ chmod u+x /usr/local/etc/rc.d/tautulli

# Start service
iocage exec __TAUTULLI_JAIL__ service tautulli start
echo Please open your web browser to http://__TAUTULLI_IP__:8181
