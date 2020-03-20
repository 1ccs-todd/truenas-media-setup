include(variables.m4)dnl
#!/bin/sh
# $FreeBSD$
#
# PROVIDE: sonarr
# REQUIRE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# sonarr_enable (bool):	Set to NO by default.
#			Set it to YES to enable it.
# sonarr_data_dir:	Directory where sonarr configuration
#			data is stored.
#			Default: /home/${sonarr_user}/.config/Sonarr
# sonarr_user:	The user account sonarr daemon runs as what
#			you want it to be. It uses '%%USER%%' user by
#			default. Do not sets it as empty or it will run
#			as root.
# sonarr_group:	The group account sonarr daemon runs as what
#			you want it to be. It uses '%%GROUP%%' group by
#			default. Do not sets it as empty or it will run
#			as wheel.

. /etc/rc.subr
name=sonarr
rcvar=${name}_enable
load_rc_config $name

: ${sonarr_enable:="NO"}
: ${sonarr_user:="__MEDIA_USER__"}
: ${sonarr_group:="__MEDIA_GROUP__"}
: ${sonarr_data_dir:="/config"}

pidfile="${sonarr_data_dir}/sonarr.pid"
stop_postcmd="${name}_poststop"
start_precmd="${name}_prestart"

command="/usr/sbin/daemon"
procname="/usr/local/bin/mono"
command_args="-f -p ${pidfile} ${procname} /usr/local/share/Sonarr/Sonarr.exe --data=${sonarr_data_dir} --nobrowser"

sonarr_poststop()
{
        rm $pidfile
}
sonarr_prestart() {
	if [ ! -d ${sonarr_data_dir} ]; then
	install -d -o ${sonarr_user} -g ${sonarr_group} ${sonarr_data_dir}
	fi
	export XDG_CONFIG_HOME=${sonarr_data_dir}
}

run_rc_command "$1"
