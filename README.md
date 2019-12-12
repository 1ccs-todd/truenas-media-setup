# freenas-media-setup
Cribbed from https://gist.github.com/mow4cash/e2fd4991bd2b787ca407a355d134b0ff

***DISCLAIMER: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing.  Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/

**Warning: Default __IOCAGE_RELEASE__ in 'variables.m4' is configured to build 11.3-RELEASE jails.  This requires FreeNAS version 11.2-U7 or 11.3-BETA1**

The goal is to make a customizable installation script to setup complete media management including Plex, Tautulli, Sonarr, Radarr, Lidarr, Jackett, Transmission, and Organizr on any FreeNAS server.

Ombi is no longer supported as Ombi 2.x is no longer being developed and Ombi 3.x is not usable until there is proper support for .net-core on FreeBSD


**Basic Guide:** 
1) download the master.zip from this repo and unpack it to a folder on your FreeNAS server.
2) ssh (preferred) or use shell from the Web-UI of FreeNAS
3) enter path where you unpacked the master.zip file and edit 'variables.m4'
    * Recommended variables to edit: 
                                    ```
                                     __POOL__;
                                     __MEDIA_DATASET__;
                                     __DEFAULT_ROUTER__;
                                     __JACKETT_IP__;
                                     __ORGANIZR_IP__;
                                     __PLEX_IP__;
                                     __RADARR_IP__;
                                     __SONARR_IP__;
                                     __TAUTULLI_IP__;
                                     __TRANSMISSION_IP__;
                                     ```
4) run 'make' to build custom install scripts based on 'variables.m4'
5) Review "Freenas 11.3 Setup.md".  A customized setup guide for each installation.
6) Enter "chmod u+x *.sh" to ensure execution of the installation scripts.
7) Execute '.\/\<JAIL\>_setup.sh' to install whichever jails you desire. reply 'y' to any prompts
8) If you desire VPN protection for your Transmission jail, execute "transmission_add_VPN.sh" and place your working openvpn.conf file where the script recommends.

------
***Post Installation Steps***

TRANSMISSION:
The default transmission settings will prevent any access to the WebUI from anything other than from localhost. We need to access edit the settings file for transmission to fix this to do so we need to stop transmission and edit settings.json file for Transmission.
iocage exec transmission service transmission stop

Using your favorite editor edit /mnt/tank1/apps/transmission/config/transmission-home/settings.json and find the lines prefixed with rpc-whitelist. You have 2 options disabling the whitelist or adding your IP to the whitelist.

A) To disable the whitelist change the following lines:
```
"rpc-whitelist-enabled": true,
```
to
```
"rpc-whitelist-enabled": false,
```

B) To add your IP edit the line below to include your IP. The setting is a comma separated list, so if your IP was 192.168.1.100 you would change it as follows.
```
"rpc-whitelist": "127.0.0.1",
```
to
```
"rpc-whitelist": "127.0.0.1,192.168.1.100",
```

After you have completed either of these you can start transmission again.
iocage exec transmission service transmission start

ORGANIZR:
Navigate to http://<JailIP> and set the database location to "/config" and pick your timezone.
