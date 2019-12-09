changequote(`[[[', `]]]')dnl
include(variables.m4)
iocage exec __LIDARR_JAIL__ chmod u+x /usr/local/etc/rc.d/jackett
iocage exec __LIDARR_JAIL__ sysrc "jackett_enable=YES"
iocage exec __LIDARR_JAIL__ service jackett start