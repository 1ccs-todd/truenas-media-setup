changequote(`[[[', `]]]')dnl
include(variables.m4)dnl
FreeNAS 13.1, 13.2
=======

***WARNING READ THIS: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing, stuff may be nedd to be changed for your own use. These include but are not limited too JAIL AND ROUTER IPs, YOUR FREENAS MAIN VOLUME,THE MOST RECENT RELEASE OF DOWNLOADED FILES Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/


***Setup Structure***
```
__POOL__ > __MEDIA_DATASET__ >  -__SONARR_COMPLETED__
                 -__RADARR_COMPLETED__
                 -__LIDARR_COMPLETED__
                 -downloads > -__SONARR_DOWNLOADS__
                              -__RADARR_DOWNLOADS__
                              -__LIDARR_DOWNLOADS__
                              -complete
                              -incomplete
                              -__SABNZBD_FILES__
                            ```

You have pool named "__POOL__". And created a dataset named "__MEDIA_DATASET__" owned by the default freenas user __MEDIA_USER__:__MEDIA_GROUP__. The dataset contains the folders: __SONARR_COMPLETED__, __RADARR_COMPLETED__, __LIDARR_COMPLETED__ and downloads. You also have a dataset named "__APPS_DATASET__" to hold the jails config data.
```
------

***ISSUES RESOLVED IN INSTALL SCRIPTS:***

Permissions
------  
For Sonarr, Radarr, Lidarr, Bazarr and Transmission/Deluge to share files, the default user is changed to to __MEDIA_USER__:__MEDIA_GROUP__ so the jails can work together properly.

MONO 5.20 compatibility
------
Sonarr and Lidarr have moved away from mono 5.10.  For these two, PORTS are installed to apply a patch to v5.20.1.34 and installed. Installation of these two jails takes a LONG time due to Ports installation and compiling Mono from source.

OPENVPN
------
A VPN may not be desired by everyone. Execute "torrent_add_VPN.sh" to process the necessary additions for __TORRENT_JAIL__.

------

***Complete Media setup including (dates show the last successful test):***

+ [Plex](#plex) 12/30/19
+ [Emby](#emby) 07/25/23
+ [Jelllyfin](#jellyfin) 07/25/23
+ [Transmission](#torrent)
+ [Deluge](#torrent) 
+ [Radarr](#radarr) 07/25/23
+ [Lidarr](#lidarr) 07/25/23
+ [Sonarr](#sonarr) 07/25/23
+ [Prowlarr](#prowlarr) 07/25/23
+ [Tautulli](#tautulli) 12/30/19
+ [Organizr V2](#organizr) 12/30/19
+ [Sabnzbd](#sabnzbd) 07/25/23
+ [Bazarr](#bazarr) 07/23/23

Ombi is no longer supported as Ombi 2.x is no longer being developed actively and Ombi 3.x is not usable until there is proper support for .net-core on FreeBSD

------
Configuration:
+ [Backups](#backups)
+ [Common Commands](#commands)
+ [Testing/Updates](#testing)
+ [Default Jail Ports/UID/Location](#default)

<a name="plex"></a>
***Plex***
------
```
include(./plex_setup.sh)
```

<a name="torrents"></a>
***Transmission/Deluge***
-------
```
include(torrents_setup.sh)
```
```
# you may need to change the white list in settings.json to your preferred settings. The script allows EVERYONE.
```

<a name="sonarr"></a>
***Sonarr V3***
-----
```
include(sonarr_setup.sh)
```

<a name="radarr"></a>
***Radarr***
------
```
include(radarr_setup.sh)
```

<a name="lidarr"></a>
***Lidarr V7.1.x***
-----
```
include(lidarr_setup.sh)
```

<a name="organizr"></a>
***Organizr V2***
------
```
include(organizr_setup.sh)
```
<details><summary>CLICK TO SHOW nginx.conf</summary>
<p>

```
include(bin/organizr_nginx.conf)
```

</p>
</details>

<a name="Prowlarr"></a>
***Prowlarr***
------
```
include(prowlarr_setup.sh)
```

<a name="tautulli"></a>
***Tautulli***
-----
```
include(tautulli_setup.sh)
```

<a name="sabnzbd"></a>
***Sabnzbd***
-------
```
include(sabnzbd_setup.sh)
```

<a name="backups"></a>
***Backups***
-------
**Important files**
```
Backup your entire __APPS_DATASET__ folder
```

<a name="common commands"></a>
**Common Commands**
-----
https://www-uxsup.csx.cam.ac.uk/pub/doc/suse/suse9.0/userguide-9.0/ch24s04.html
```
cd /directorypath	: Change to directory.
chmod [options] mode filename	: Change a file’s permissions.
chown [options] filename :	Change who owns a file.
cp [options] :source destination	: Copy files and directories.
ln -s test symlink	: Creates a symbolic link named symlink that points to the file test
mkdir [options] directory	: Create a new directory.
mv -i myfile yourfile : Move the file from "myfile" to "yourfile". This effectively changes the name of "myfile" to "yourfile".
mv -i /data/myfile :	Move the file from "myfile" from the directory "/data" to the current working directory.
rm [options] directory	: Remove (delete) file(s) and/or directories.
tar [options] filename :	Store and extract files from a tarfile (.tar) or tarball (.tar.gz or .tgz).
touch filename :	Create an empty file with the specified name.
```

<a name="testing"></a>
***Testing/Updates***
-----
```
iocage exec <jail> pkg upgrade <name of service>
iocage exec <jail> pkg update && pkg upgrade

iocage exec <jail> service <name of service> start
iocage exec <jail> service <name of service> restart
iocage exec <jail> service <name of service> stop

```

<a name="default"></a>
**Default User Ports/UID/Location**
-----
```
PORT - SERVICE - USER (UID)
radarr- 7878 - __RADARR_USER__ (__RADARR_UID__) 
sonarr- 8989 - __SONARR_USER__ (__SONARR_UID__)
prowlarr - 9117 - __PROWLARR_USER__ (__PROWLARR_UID__)
0rganizr - 80 - organizr (www)
plexmediaserver 32400 - plex (972)
transmission - 9091 -transmission (921) 
tautulli - 8181 - __TAUTULLI_USER__ (__TAUTULLI_UID__)
ombi - 3579 - ombi (819)
```
