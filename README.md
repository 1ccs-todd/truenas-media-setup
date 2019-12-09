# freenas-media-setup
Cribbed from https://gist.github.com/mow4cash/e2fd4991bd2b787ca407a355d134b0ff

***WARNING READ THIS: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing.  Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/


The goal is to make a customizable installation script to setup complete media management including Plex, Tautulli, Sonarr, Radarr, Lidarr, Jackett, Transmission, and Organizr on any FreeNAS server.

***Setup Structure***
```
__POOL__ > __MEDIA_DATASET__ >  -series
                 -movies
                 -downloads > -radarr
                              -sonarr
                              -complete
                              -incomplete
```


Basic Guide:
1) download the master.zip from this repo and unpack it to a folder on your FreeNAS server.
2) ssh (preferred) or use shell from the Web-UI of FreeNAS
3) enter path where you unpacked the master.zip file and edit 'variables.m4'
4) run 'make' to build custom install scripts based on 'variables.m4'
5) ... more to follow ...
