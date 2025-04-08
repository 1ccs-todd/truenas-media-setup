# freenas-media-setup

***DISCLAIMER: The project is no longer maintained. Read the code carefully to understand what you are doing.  Use at your own risk.***  
*** These worked well for me on TN 12 & 13 systems.  TN Core is beinge phased out for Community Edition (Scale) ***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/  

The goal is to make a customizable installation script to setup complete media management including Plex, Tautulli, Sonarr, Radarr, Lidarr, Jackett, Transmission or Deluge, Organizr, Ombi, and Sabnzbd on TrueNAS CORE server.  



**Basic Guide:**  
1) download the latest release from this repo and unpack it to a folder on your TrueNAS CORE server.  
2) ssh (preferred) or use shell from the Web-UI of TrueNAS  
3) enter path where you unpacked the master.zip  
4) copy 'variables.m4.sample' to 'variables.m4' and open for editing...  
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
                                     __TORRENTS_IP__;
                                     __SABNZBD_IP__;
```

5) run 'make' to build the custom install scripts based on 'variables.m4'  
6) Review "Truenas 13.x Setup.md".  A customized pre-install review guide for each installation.  
   (I use Chrome with MarkDown Viewer Extension.)  
7) Enter "chmod u+x *.sh" to ensure execution of the installation scripts.  
8) Execute './\<JAIL\>_setup.sh' to install whichever jails you desire.   
8a) torrents_setup.sh replaces old scripts.  During execution, prompts added to decide daemon (Deluge/Transmission) and if adding VPN protection.
8b) VPN protection prompts for universal Openvpn or PrivateInternetAccess specific (wireguard/openvpn) configurations.

------  
***Post Installation Steps***  

**TRANSMISSION:**  
The install script changes the default transmission settings to ALLOW everyone access to the WebUI. If this is not desired, follow the steps below:  
We need to access and edit the settings file for transmission to fix this.  To do so we need to stop transmission and edit settings.json file for Transmission.  
```iocage exec transmission service transmission stop```  

Using your favorite editor edit /mnt/\<POOL\>/apps/\<transmission-jail\>/config/transmission-home/settings.json and find the lines prefixed with rpc-whitelist.  

A) To re-enable the whitelist change the following lines:  
``
"rpc-whitelist-enabled": false,  
``
to  
``
"rpc-whitelist-enabled": true,  
``

B) Then add your IP to the line below to include your IP. The setting is a comma separated list, so if your IP was 192.168.1.100 you would change it as follows.  
``
"rpc-whitelist": "127.0.0.1",  
``
to  
``
"rpc-whitelist": "127.0.0.1,192.168.1.100",  
``

After you have completed these two steps, you can start transmission again.  
``
iocage exec transmission service transmission start  
``
Transmission should be available at http://\<JailIP\>:9091/transmission/web/  
   
**ORGANIZR:**  
Navigate to http://\<JailIP\> and set the database location to "/config" and pick your timezone.  

**TORRENTS-VPN:**  
For standard OpenVPN, place your working openvpn.conf (and any linked ca,key,pass files) to /mnt/\<POOL\>/apps/openvpn/  
Finally, using your favorite editor, edit /mnt/\<POOL\>/apps/\<JAIL\>/config/ipfw.rules and check "tun*" device, and that the public IP of the VPN server is allowed.
