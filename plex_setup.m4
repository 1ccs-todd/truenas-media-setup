include(variables.m4)dnl
# Create the jail
echo '{"pkgs":["plexmediaserver","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "__PLEX_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__PLEX_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on" 
rm /tmp/pkg.json

# Update to the latest repo
iocage exec __PLEX_JAIL__ mkdir -p /usr/local/etc/pkg/repos
iocage exec __PLEX_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
# Apply updates from new Repo
iocage exec __PLEX_JAIL__ "pkg update && pkg upgrade -y"

# Mount storage
iocage exec __PLEX_JAIL__ mkdir -p /config
mkdir -p __APPS_ROOT__/__PLEX_JAIL__
iocage fstab -a __PLEX_JAIL__ __APPS_ROOT__/__PLEX_JAIL__ /config nullfs rw 0 0
iocage fstab -a __PLEX_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs ro 0 0

# Set permissions
iocage exec __PLEX_JAIL__ chown -R plex:plex /config

# Enable service
iocage exec __PLEX_JAIL__ sysrc "plexmediaserver_enable=YES"
iocage exec __PLEX_JAIL__ sysrc plexmediaserver_support_path="/config"
iocage exec __PLEX_JAIL__ service plexmediaserver start
echo Please open your web browser to http://__PLEX_IP__:32400/web
