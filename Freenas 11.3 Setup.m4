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

I have pool named __POOL__. I created a dataset named "__MEDIA_DATASET__" owned by the default freenas user __MEDIA_USER__:__MEDIA_GROUP__. The dataset contains the folders series,movies,downloads. Radarr, Sonarr, Transmission will need to run as the user __MEDIA_USER__:__MEDIA_GROUP__ to have access to them, this is very important and should not be overlooked. I also have a dataset named "__APPS_DATASET__" to hold the config data.
```

**Permissions**
------  
```
For Sonarr, Radarr, Lidarr, and Transmission you will have to change the default user to __MEDIA_USER__:__MEDIA_GROUP__ so the jails can work together properly.

Use the name of your plugin instead of PLUGIN

service PLUGIN onestop
chown -R __MEDIA_USER__:__MEDIA_GROUP__ /usr/local/PLUGIN (this location might be different for some of the apps)
sysrc 'PLUGIN_user=__MEDIA_USER__'
sysrc 'PLUGIN_group=__MEDIA_GROUP__'
service PLUGIN start
```




Complete Media setup including (dates show the last successful test):

+ [Plex](#plex) 12/21/18
+ [Transmission](#transmission) 12/21/18
+ [Sonarr V3](#sonarr) 12/21/18
+ [Radarr](#radarr) 12/21/18
+ [Lidarr](#lidarr) 
+ [Jackett](#jackett) 12/21/18
+ [Tautulli](#tautulli) 12/21/18
+ [Organizr V2](#organizr) 12/21/18

Ombi is no longer supported as Ombi 2.x is no longer being developed actively and Ombi 3.x is not usable until there is proper support for .net-core on FreeBSD

Configuration:
+ [Backups](#backups)
+ [Common Commands](#commands)
+ [Testing/Updates](#testing)
+ [Default Jail Ports/UID/Location](#default)

<a name="plex"></a>
Plex
------
```
include(plex_setup.sh)
```

<a name="transmission"></a>
Transmission
-------
```
include(transmission_setup.sh)
 
# you may need to change the white list in settings.json to 0.0.0.0 or set to your preferred settings
```

<a name="sonarr"></a>
Sonarr V3
-----
```
include(sonarr_setup.sh)

# create rc.d
iocage exec sonarr mkdir /usr/local/etc/rc.d
iocage exec sonarr "ee /mnt/iocage/jails/sonarr/root/usr/local/etc/rc.d/sonarr"
# use rc.d below
```

<details><summary>CLICK TO SHOW SONARR rc.d</summary>
<p>

```
include(sonarr.rc)
```

</p>
</details>

```
include(sonarr_setup-2.sh)
```

<a name="radarr"></a>
Radarr
------
```
include(radarr_setup.sh)
```
```
Create an rc file for radarr using your favorite editor at /mnt/iocage/jails/radarr/root/usr/local/etc/rc.d/radarr

iocage exec radarr mkdir /usr/local/etc/rc.d
iocage exec radarr "ee /mnt/iocage/jails/radarr/root/usr/local/etc/rc.d/radarr"

```
```
include(radarr.rc)
```
```
include(radarr_setup-2.sh)
```

<a name="lidarr"></a>
Lidarr V7.1.x
-----
```
include(lidarr_setup.sh)

# create rc.d
iocage exec lidarr mkdir /usr/local/etc/rc.d
iocage exec lidarr "ee /mnt/iocage/jails/lidarr/root/usr/local/etc/rc.d/lidarr"
# use rc.d below
```

<details><summary>CLICK TO SHOW LIDARR rc.d</summary>
<p>

```
include(lidarr.rc)
```

</p>
</details>

```
include(lidarr_setup-2.sh)
```


<a name="organizr"></a>
Organizr V2
------
```
include(organizr_setup.sh)
```
```
include(organizr_nginx.conf)
```
```
include(organizr_setup-2.sh)

#note to self renable port forwarding

I keep folders in /config for nginx,log,letsencrypt,Backups
```


<a name="jackett"></a>
Jackett
------
```
include(jackett_setup.sh)

ee __IOCAGE_ROOT__/jails/jackett/root/usr/local/etc/rc.d/jackett
```
```
include(jackett.rc)
```
```
include(jackett_setup-2.sh)
```

<a name="tautulli"></a>
Tautulli
-----

```
include(tautulli_setup.sh)
```

<a name="backups"></a>
Backups
-------
**Important files**
```
Backup your entire __APPS_DATASET__ folder
```

<a name="common commands"></a>
Common Commands
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
Testing/Updates
-----
```
iocage exec <jail> pkg upgrade <name of service>
iocage exec <jail> pkg upgrade && pkg update

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
sonarr- 8989 - 
jackett - 9117 - __JACKETT_USER__ (__JACKETT_UID__)
0rganizr - 80 - organizr (www)
plexmediaserver 32400 - plex (972)
transmission - 9091 -transmission (921) 
tautulli - 8181 - __TAUTULLI_USER__ (__TAUTULLI_UID__)
ombi - 3579 - ombi (819)
```
