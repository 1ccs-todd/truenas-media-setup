include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["mono6.8","curl","nano"]}' > /tmp/pkg.json
iocage create -n "__JACKETT_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__JACKETT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

# Update to Latest Repo
iocage exec __JACKETT_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __JACKETT_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __JACKETT_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __JACKETT_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__JACKETT_JAIL__
iocage fstab -a __JACKETT_JAIL__ __APPS_ROOT__/__JACKETT_JAIL__ /config nullfs rw 0 0

# Download jackett
iocage exec __JACKETT_JAIL__ "fetch https://github.com/Jackett/Jackett/releases/download/__JACKETT_VERSION__/Jackett.Binaries.Mono.tar.gz -o /usr/local/share"
iocage exec __JACKETT_JAIL__ "tar -xzvf /usr/local/share/Jackett.Binaries.Mono.tar.gz -C /usr/local/share"
iocage exec __JACKETT_JAIL__ rm /usr/local/share/Jackett.Binaries.Mono.tar.gz

# Configure rc.conf
iocage exec __JACKETT_JAIL__ sysrc "jackett_enable=YES"
iocage exec __JACKETT_JAIL__ sysrc jackett_data_dir="/config"

# Media permissions
iocage exec __JACKETT_JAIL__ "pw user add jackett -c jackett -u 818 -d /nonexistent -s /usr/bin/nologin"
iocage exec __JACKETT_JAIL__ chown -R jackett:jackett /usr/local/share/Jackett /config

# Install rc.d service
iocage exec __JACKETT_JAIL__ mkdir /usr/local/etc/rc.d
cp jackett.rc __IOCAGE_ROOT__/jails/__JACKETT_JAIL__/root/usr/local/etc/rc.d/jackett
iocage exec __JACKETT_JAIL__ chmod u+x /usr/local/etc/rc.d/jackett

# Start rc.d service
iocage exec __JACKETT_JAIL__ service jackett start
echo Please open your web browser to http://__JACKETT_IP__:9117
