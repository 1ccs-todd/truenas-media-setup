include(variables.m4)dnl
# Create the jail
iocage create -n "__PLEX_JAIL__" -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__PLEX_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on" 

# Update to the latest repo
iocage exec __PLEX_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
iocage exec __PLEX_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"

# Install Plex and dependencies
iocage exec __PLEX_JAIL__ pkg install -y plexmediaserver ca_root_nss nano

# Mount storage
iocage exec __PLEX_JAIL__ "mkdir -p /config"
iocage fstab -a __PLEX_JAIL__ __APPS_ROOT__/plex /config nullfs rw 0 0
iocage fstab -a __PLEX_JAIL__ __MEDIA_ROOT__ /mnt/media nullfs ro 0 0

# Set permissions
iocage exec __PLEX_JAIL__ chown -R plex:plex /config

# Enable service
iocage exec __PLEX_JAIL__ sysrc "plexmediaserver_enable=YES"
iocage exec __PLEX_JAIL__ sysrc plexmediaserver_support_path="/config"
iocage exec __PLEX_JAIL__ service plexmediaserver start
