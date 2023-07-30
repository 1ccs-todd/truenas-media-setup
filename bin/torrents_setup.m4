include(variables.m4)dnl
#!/usr/bin/env bash
# Only allow script to run as
echo "
################################
    torrents_setup.sh
################################
"

if [ "$(whoami)" != "root" ]; then
  echo "This script needs to be run as root. Try again with 'sudo $0'"
  exit 1
fi

# Define torrent client
echo -n "Choose a Torrent Daemon ([t]ransmission,[d]eluge: "
read daemoninput
echo
if [ -z "$daemoninput" ]; then
        echo daemon selection is required, aborting.
exit 1
fi
DAEMON_TYPE="transmission"
if echo ${daemoninput:0:1} | grep -iq d; then
  DAEMON_TYPE="deluge"

  # Create Deluge jail
  echo '{"pkgs":["bash","unzip","unrar","deluge","nano"]}' > /tmp/pkg.json
  iocage create -n "__TORRENT_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TORRENT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
  rm /tmp/pkg.json

  # Update to latest repo and apply any updates
  iocage exec __TORRENT_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
  iocage exec __TORRENT_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
  # Apply updates from new Repo
  iocage exec __TORRENT_JAIL__ "pkg update && pkg upgrade -y"

  # Mount storage
  iocage exec __TORRENT_JAIL__ mkdir -p /config/deluge
  mkdir -p __APPS_ROOT__/__TORRENT_JAIL__
  iocage fstab -a __TORRENT_JAIL__ __APPS_ROOT__/__TORRENT_JAIL__ /config/deluge nullfs rw 0 0
  iocage fstab -a __TORRENT_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

  # Configure Deluge services
  iocage exec __TORRENT_JAIL__ sysrc deluged_enable=YES
  iocage exec __TORRENT_JAIL__ sysrc deluge_web_enable=YES
  iocage exec __TORRENT_JAIL__ sysrc "deluged_confdir=/config/deluge"
  iocage exec __TORRENT_JAIL__ sysrc "deluge_web_confdir=/config/deluge"
  iocage exec __TORRENT_JAIL__ sysrc deluged_user=media
  iocage exec __TORRENT_JAIL__ sysrc deluge_web_user=media

  # Fix permissions
  iocage exec __TORRENT_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
  iocage exec __TORRENT_JAIL__  chown -R media:media /config

  ## Update Deluge configuration
  # Edit Deluge web-access
  iocage exec __TORRENT_JAIL__ service deluged start
  iocage exec __TORRENT_JAIL__ service deluged stop
  iocage exec __TORRENT_JAIL__ sed -i '' -e 's?"allow_remote": false?"allow_remote": true?g' /config/deluge/core.conf
  # Fix web-access rc script
  iocage exec __TORRENT_JAIL__ sed -i '' -e 's?deluge_web_home=$(pw user show ${deluge_web_user} | cut -d : -f 9)?deluge_web_home=$deluge_web_confdir?g' /usr/local/etc/rc.d/deluge_web
  # Configure downloads
  iocage exec __TORRENT_JAIL__ sed -i '' -e 's?"download_location": "/Downloads"?"download_location": "/media/downloads/z_incomplete"?g' /config/deluge/core.conf
  iocage exec __TORRENT_JAIL__ sed -i '' -e 's?"move_completed": false?"move_completed": true?g' /config/deluge/core.conf
  iocage exec __TORRENT_JAIL__ sed -i '' -e 's?"move_completed_path": "/Downloads"?"move_completed_path": "/media/downloads/completed"?g' /config/deluge/core.conf

  # Start service
  iocage exec __TORRENT_JAIL__ service deluged start
  iocage exec __TORRENT_JAIL__ service deluge_web start
  echo Please open your web browser to http://__TORRENT_IP__:8112

else

  # Create Transmission jail
  echo '{"pkgs":["bash","unzip","unrar","transmission","nano"]}' > /tmp/pkg.json
  iocage create -n "__TORRENT_JAIL__" -p /tmp/pkg.json -r __IOCAGE_RELEASE__ ip4_addr="__DEFAULT_INTERFACE__|__TORRENT_IP__/__DEFAULT_CIDR__" defaultrouter="__DEFAULT_ROUTER__" vnet="on" allow_raw_sockets="1" boot="on"
  rm /tmp/pkg.json

  # Update to latest repo and apply any updates
  iocage exec __TORRENT_JAIL__ "mkdir -p /usr/local/etc/pkg/repos"
  iocage exec __TORRENT_JAIL__ "echo -e 'FreeBSD: { url: \"pkg+http://pkg.FreeBSD.org/\${ABI}/latest\" }' > /usr/local/etc/pkg/repos/FreeBSD.conf"
  # Apply updates from new Repo
  iocage exec __TORRENT_JAIL__ "pkg update && pkg upgrade -y"

  # Mount storage
  iocage exec __TORRENT_JAIL__ mkdir -p /config/transmission
  mkdir -p __APPS_ROOT__/__TORRENT_JAIL__
  iocage fstab -a __TORRENT_JAIL__ __APPS_ROOT__/__TORRENT_JAIL__ /config/transmission nullfs rw 0 0
  iocage fstab -a __TORRENT_JAIL__ __MEDIA_ROOT__ /__MOUNT_LOCATION__ nullfs rw 0 0

  # Configure Transmission service
  iocage exec __TORRENT_JAIL__ sysrc transmission_enable=YES
  iocage exec __TORRENT_JAIL__ sysrc "transmission_conf_dir=/config/transmission"
  iocage exec __TORRENT_JAIL__ sysrc "transmission_download_dir=/__MOUNT_LOCATION__/downloads/complete"
  iocage exec __TORRENT_JAIL__ sysrc transmission_user=media
  iocage exec __TORRENT_JAIL__ sysrc transmission_group=media

  # Fix permissions
  iocage exec __TORRENT_JAIL__ "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
  iocage exec __TORRENT_JAIL__ "pw groupmod media -m transmission"
  iocage exec __TORRENT_JAIL__  chown -R media:media /config

  # Update Transmission configuration
  iocage exec __TORRENT_JAIL__  service transmission start
  iocage exec __TORRENT_JAIL__  service transmission stop
  iocage exec __TORRENT_JAIL__  sed -i '' -e 's?"rpc-whitelist-enabled": true?"rpc-whitelist-enabled": false?g' /config/transmission/settings.json

  # Start service
  iocage exec __TORRENT_JAIL__ service transmission start
  echo Please open your web browser to http://__TORRENT_IP__:9091

fi

# Query for optional VPN setup
read -p "Add VPN protection to __TORRENT_JAIL__? [y/n]: " vpninput
if echo ${vpninput:0:1} | grep -iq y; then

  # Cconfigure jail for tun device
  iocage set allow_tun="1" __TORRENT_JAIL__
  iocage set allow_mount="1" __TORRENT_JAIL__ 
  iocage set allow_mount_devfs="1" __TORRENT_JAIL__ 
  iocage restart __TORRENT_JAIL__

  # Define VPN type
  read -p "Enter 'u' for universal OpenVPN or 'p' for PrivateInternetAccess specific VPN connection: " VPNTYPE
  if echo ${VPNTYPE:0:1} | grep -iq p; then
    # Install PIA VPN 

    # Mount storage
    iocage exec __TORRENT_JAIL__ mkdir -p /config/pia
    mkdir -p __APPS_ROOT__/piat
    iocage fstab -a __TORRENT_JAIL__ __APPS_ROOT__/piat /config/pia nullfs rw 0 0

    # Install run PIA scripts
    iocage exec __TORRENT_JAIL__ pkg install -y  git-tiny
    iocage exec __TORRENT_JAIL__ "git clone https://github.com/1ccs-todd/manual-connections.git /config/pia"
    iocage exec __TORRENT_JAIL__ "cd /config/pia; ./run_setup.sh"

    # Configure PIA service
    if [ $PIA_AUTOCONNECT:0:1 = "w" ]; then

      # Configure PIA wireguard service
      iocage exec __TORRENT_JAIL__ sysrc wireguard_enable="YES"
      # Disable unneeded devfs for wireguard
      iocage set allow_mount="0" __TORRENT_JAIL__
      iocage set allow_mount_devfs="0" __TORRENT_JAIL__

    else

      # Configure PIA openvpn service
      iocage exec __TORRENT_JAIL__ sysrc openvpn_enable="YES"
      iocage exec __TORRENT_JAIL__ sysrc openvpn_dir="/config/pia/pia-info"
      iocage exec __TORRENT_JAIL__ sysrc openvpn_configfile="/config/pia/pia-info/pia.ovpn"
    fi
    # Remind to schedule port refresh if PF is enabled.
    if [ $PIA_PF:0:1 = "y" ]; then
      # Schedue port refresh for PF stability.
      echo "*/15 * * * * /config/pia/refresh_pia_port.sh > /pia-info/refresh.log 2>&1" >> __IOCAGE_ROOT__/jails/__TORRENT_JAIL__/root/tmp/crontab
      iocage exec __TORRENT_JAIL__ crontab /tmp/crontab
      rm  __IOCAGE_ROOT__/jails/__TORRENT_JAIL__/root/tmp/crontab
    fi

  else

# Install universal OpenVPN
    # Mount storage
    iocage exec __TORRENT_JAIL__ mkdir -p /config/openvpn
    mkdir -p __APPS_ROOT__/openvpn
    iocage fstab -a __TORRENT_JAIL__ __APPS_ROOT__/openvpn /config/openvpn nullfs rw 0 0
    read -rp $'IMPORTANT: Place your working openvpn.conf and any linked files (ca,key,pass) into __APPS_ROOT__/openvpn/  (Press <Enter> to continue)\n' key

    # Install OpenVPN
    iocage exec __TORRENT_JAIL__ pkg install -y openvpn

    # Configure firewall
    if [ ! -f __IOCAGE_ROOT__/jails/__TORRENT_JAIL__/root/config/openvpn/ipfw.rules ];then
      cp -n bin/openvpn_ipfw.rules __IOCAGE_ROOT__/jails/__TORRENT_JAIL__/root/config/openvpn/ipfw.rules
    fi
    iocage exec __TORRENT_JAIL__ "chown 0:0 /config/openvpn/ipfw.rules"
    iocage exec __TORRENT_JAIL__ "chmod 600 /config/openvpn/ipfw.rules"

    # Configure services
    iocage exec __TORRENT_JAIL__ sysrc firewall_enable="YES"
    iocage exec __TORRENT_JAIL__ sysrc firewall_script="/config/openvpn/ipfw.rules"
    iocage exec __TORRENT_JAIL__ sysrc openvpn_enable="YES"
    iocage exec __TORRENT_JAIL__ sysrc openvpn_dir="/config/openvpn/"
    iocage exec __TORRENT_JAIL__ sysrc openvpn_configfile="/config/openvpn/openvpn.conf"

    read -rp $'IMPORTANT: Make sure you edit tun* device and the IP for VPN server to __APPS_ROOT__/openvpn/ipfw.rules  (Press <Enter> to continue)\n' key
  fi

  iocage restart __TORRENT_JAIL__
fi
