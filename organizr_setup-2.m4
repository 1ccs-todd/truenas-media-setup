include(variables.m4)dnl
iocage exec __ORGANIZR_JAIL__ sysrc nginx_enable=YES
iocage exec __ORGANIZR_JAIL__ sysrc php_fpm_enable=YES
iocage exec __ORGANIZR_JAIL__ service nginx start
iocage exec __ORGANIZR_JAIL__ service php-fpm start

#important step Navigate to http://JailIP and set the follow the setup database location to "/config/Organizr" and Organizr for the database name. If you have an exsisting config file in the database location once you complete the setup restart the jail and login with you exsisting credentials.

# link my exsisting nginx config, you need to upload your own or edit the exsisting
iocage exec __ORGANIZR_JAIL__ service nginx stop
iocage exec __ORGANIZR_JAIL__ rm /usr/local/etc/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ ln -s /config/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf
iocage exec __ORGANIZR_JAIL__ service nginx start
