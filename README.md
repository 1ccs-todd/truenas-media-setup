# freenas-media-setup
Cribbed from https://gist.github.com/mow4cash/e2fd4991bd2b787ca407a355d134b0ff

***DISCLAIMER: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing.  Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/

**Warning: Scripts are configured to build 11.3-RELEASE jails.  This requires FreeNAS version 11.2-U7 or 11.3-BETA1.**

The goal is to make a customizable installation script to setup complete media management including Plex, Tautulli, Sonarr, Radarr, Lidarr, Jackett, Transmission, and Organizr on any FreeNAS server.

***Setup Structure***
```
__POOL__ > __MEDIA_DATASET__ >  -series
                                -movies
                                -downloads > -radarr
                                             -sonarr
                                             -complete
                                             -incomplete
           __APPS_DATASET__                                  
```


Basic Guide:
1) download the master.zip from this repo and unpack it to a folder on your FreeNAS server.
2) ssh (preferred) or use shell from the Web-UI of FreeNAS
3) enter path where you unpacked the master.zip file and edit 'variables.m4'
4) run 'make' to build custom install scripts based on 'variables.m4'
    * Recommended to edit variables: "__POOL__"
                                     "__MEDIA_DATASET__"
                                     "__DEFAULT_ROUTER__"
                                     "__JACKETT_IP__"
                                     "__ORGANIZR_IP__"
                                     "__PLEX_IP__"
                                     "__RADARR_IP__"
                                     "__SONARR_IP__"
                                     "__TAUTULLI_IP__"
                                     "__TRANSMISSION_IP__"
                                          
5) ... more to follow ...
