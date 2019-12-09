include(variables.m4)dnl
iocage exec __RADARR_JAIL__ chmod u+x /usr/local/etc/rc.d/radarr
iocage exec __RADARR_JAIL__ sysrc "radarr_enable=YES"
iocage exec __RADARR_JAIL__ service radarr start
