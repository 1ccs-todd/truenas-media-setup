changequote(`[[[', `]]]')dnl
include(variables.m4)dnl
FreeNAS 11.2-U7, 11.3
=======

***WARNING READ THIS: This page contains incomplete and possibly incorrect info. The page is constantly being edited and worked on. Many of these should work but some may be broken. Read the code carefully to understand what you are doing, stuff may be nedd to be changed for your own use. These include but are not limited too JAIL AND ROUTER IPs, YOUR FREENAS MAIN VOLUME,THE MOST RECENT RELEASE OF DOWNLOADED FILES Use at your own risk.***

Thanks to the creator of this guide https://www.ixsystems.com/community/resources/fn11-2-iocage-jails-plex-tautulli-sonarr-radarr-lidarr-jackett-transmission-organizr.58/


***Setup Structure***
```
__POOL__ > __MEDIA_DATASET__ >  -series
                 -movies
                 -downloads > -radarr
                              -sonarr
                              -complete
                              -incomplete
                              -recycle bin   
                            ```

You have pool named "__POOL__". And created a dataset named "__MEDIA_DATASET__" owned by the default freenas user __MEDIA_USER__:__MEDIA_GROUP__. The dataset contains the folders: series,movies, and downloads. You also have a dataset named "__APPS_DATASET__" to hold the config data.

```
***ISSUES RESOLVED IN INSTALL SCRIPTS:***
```
Permissions
------  
For Sonarr, Radarr, Lidarr, and Transmission you will have to change the default user to __MEDIA_USER__:__MEDIA_GROUP__ so the jails can work together properly.
MONO 5.20 compatibility
------
Sonarr and Lidarr have moved away from mono 5.10.  For these two, PORTS are installed to apply a patch to v5.20.1.34 and installed. 
OPENVPN
------
A VPN may not be desired by everyone. Execute "transmission_add_VPN.sh" to process the necessary additions for __TRANSMISSION_JAIL__.

------

***Complete Media setup including (dates show the last successful test):***

+ [Plex](#plex) 12/xx/19
+ [Transmission](#transmission) 12/xx/19
+ [Sonarr V3](#sonarr) 12/xx/19
+ [Radarr](#radarr) 12/xx/19
+ [Lidarr](#lidarr) 12/xx/19
+ [Jackett](#jackett) 12/xx/19
+ [Tautulli](#tautulli) 12/xx/19
+ [Organizr V2](#organizr) 12/xx/19

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
include(plex_setup.sh)
```

<a name="transmission"></a>
***Transmission***
-------
```
include(transmission_setup.sh)
 
# you may need to change the white list in settings.json to 0.0.0.0 or set to your preferred settings
```

<a name="sonarr"></a>
***Sonarr V3***
-----
```
include(sonarr_setup.sh)
```

<details><summary>CLICK TO SHOW SONARR rc.d</summary>
<p>

```
include(sonarr.rc)
```

</p>
</details>

<a name="radarr"></a>
***Radarr***
------
```
include(radarr_setup.sh)
```

<details><summary>CLICK TO SHOW RADARR rc.d</summary>
<p>

```
include(radarr.rc)
```

</p>
</details>

<a name="lidarr"></a>
***Lidarr V7.1.x***
-----
```
include(lidarr_setup.sh)
```

<details><summary>CLICK TO SHOW LIDARR rc.d</summary>
<p>

```
include(lidarr.rc)
```

</p>
</details>

<a name="organizr"></a>
***Organizr V2***
------
```
include(organizr_setup.sh)
```
<details><summary>CLICK TO SHOW nginx.conf</summary>
<p>

```
include(organizr_nginx.conf)
```

</p>
</details>

<a name="jackett"></a>
***Jackett***
------
```
include(jackett_setup.sh)
```

<details><summary>CLICK TO SHOW JACKETT rc.d</summary>
<p>

```
include(jackett.rc)
```

</p>
</details>

<a name="tautulli"></a>
***Tautulli***
-----
```
include(tautulli_setup.sh)
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
jackett - 9117 - __JACKETT_USER__ (__JACKETT_UID__)
0rganizr - 80 - organizr (www)
plexmediaserver 32400 - plex (972)
transmission - 9091 -transmission (921) 
tautulli - 8181 - __TAUTULLI_USER__ (__TAUTULLI_UID__)
ombi - 3579 - ombi (819)
```
