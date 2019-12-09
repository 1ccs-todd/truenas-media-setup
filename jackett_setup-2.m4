include(variables.m4)dnl
iocage exec __JACKETT_JAIL__ chmod u+x /usr/local/etc/rc.d/jackett
iocage exec __JACKETT_JAIL__ sysrc "jackett_enable=YES"
iocage exec __JACKETT_JAIL__ service jackett start
