"Freenas 11.3 Setup.md" :
	m4 "plex_setup.m4" > "plex_setup.sh"
	m4 "transmission_setup.m4" > "transmission_setup.sh"
	m4 "sonarr.m4" > "sonarr.rc"
	m4 "sonarr_setup.m4" > "sonarr_setup.sh"
	m4 "radarr.m4" > "radarr.rc"
	m4 "radarr_setup.m4" > "radarr_setup.sh"
	m4 "lidarr.m4" > "lidarr.rc"
	m4 "lidarr_setup.m4" > "lidarr_setup.sh"
	m4 "jackett.m4" > "jackett.rc"
	m4 "jackett_setup.m4" > "jackett_setup.sh"
	m4 "organizr_nginx.m4" > "organizr_nginx.conf"
	m4 "organizr_setup.m4" > "organizr_setup.sh"
	m4 "organizr_setup-2.m4" > "organizr_setup-2.sh"
	m4 "tautulli_setup.m4" > "tautulli_setup.sh"
	m4 "Freenas 11.3 Setup.m4" > "Freenas 11.3 Setup.md"
clean :
	rm "Freenas 11.3 Setup.md"
	rm "plex_setup.sh"
	rm "transmission_setup.sh"
	rm "sonarr.rc"
	rm "sonarr_setup.sh"
	rm "radarr.rc"
	rm "radarr_setup.sh"
	rm "lidarr.rc"
	rm "lidarr_setup.sh"
	rm "jackett.rc"
	rm "jackett_setup.sh"
	rm "organizr_setup.sh"
	rm "organizr_nginx.conf"
	rm "tautulli_setup.sh"
