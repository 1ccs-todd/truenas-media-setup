include(variables.m4)dnl
iocage exec __SONARR_JAIL__ chmod u+x /usr/local/etc/rc.d/sonarr
iocage exec __SONARR_JAIL__ sysrc "sonarr_enable=YES"
iocage exec __SONARR_JAIL__ service sonarr start
