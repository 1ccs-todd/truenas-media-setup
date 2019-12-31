# freenas-media-setup
Cribbed from https://gist.github.com/mow4cash/e2fd4991bd2b787ca407a355d134b0ff

Mono 5.20 additions cribbed from https://www.ixsystems.com/community/resources/how-to-manually-upgrade-mono-from-5-10-to-5-20-in-a-freenas-jail.126/

***DISCLAIMER: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing.  Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/

**Warning: Default __IOCAGE_RELEASE__ in 'variables.m4' is configured to build 11.3-RELEASE jails.  This requires FreeNAS version 11.2-U7 or 11.3-RC1**

The goal is to make a customizable installation script to setup complete media management including Plex, Tautulli, Sonarr, Radarr, Lidarr, Jackett, Transmission, Organizr, and Sabnzbd on any FreeNAS server.

Ombi is no longer supported as Ombi 2.x is no longer being developed and Ombi 3.x is not usable until there is proper support for .net-core on FreeBSD


**Basic Guide:** 
1) download the latest release from this repo and unpack it to a folder on your FreeNAS server.
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
                                     __SABNZBD_IP__;
                                     ```
4) run 'make' to build custom install scripts based on 'variables.m4'
5) Review "Freenas 11.3 Setup.md".  A customized manual installation guide for each FreeNAS installation.
   - I use Chrome with MarkDown Viewer Extension.
6) Enter "chmod u+x *.sh" to ensure execution of the installation scripts.
7) Execute '.\/\<JAIL\>_setup.sh' to install whichever jails you desire.
8) If you desire VPN protection for your Transmission jail, execute "transmission_add_VPN.sh" and place your working openvpn.conf file where the script recommends.

------
***Post Installation Steps***

TRANSMISSION:
The install script changes the default transmission settings to ALLOW everyone access to the WebUI. If this is not desired, follow the steps below:
We need to access and edit the settings file for transmission to fix this.  To do so we need to stop transmission and edit settings.json file for Transmission.
```iocage exec transmission service transmission stop```

Using your favorite editor edit /mnt/\<POOL\>/apps/\<transmission-jail\>/config/transmission-home/settings.json and find the lines prefixed with rpc-whitelist.

A) To re-enable the whitelist change the following lines:
```
"rpc-whitelist-enabled": false,
```
to
```
"rpc-whitelist-enabled": true,
```

B) Then add your IP to the line below to include your IP. The setting is a comma separated list, so if your IP was 192.168.1.100 you would change it as follows.
```
"rpc-whitelist": "127.0.0.1",
```
to
```
"rpc-whitelist": "127.0.0.1,192.168.1.100",
```

After you have completed these two steps, you can start transmission again.
```iocage exec transmission service transmission start```
Transmission should be available at http://\<JailIP\>:9091/transmission/web/
   
ORGANIZR:
Navigate to http://\<JailIP\> and set the database location to "/config" and pick your timezone.

TRANSMISSION-VPN:
The install script prompts for the extra steps that MUST be made.  Here is a recap:

First, place your working openvpn.con (and any linked ca,key,pass files) to /mnt/\<POOL\>/apps/\<transmission-jail\>/config/
Second, using your favorite editor, edit /mnt/\<POOL\>/apps/\<transmission-jail\>/config/ipfw.rules and change "tun*" to whatever tun device OpenVPN created (typically tun0), and change "<IP of VPN Entrance Node>" to the public IP of the VPN server.
